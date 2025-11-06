#!/usr/bin/env python3
"""Dynamic dnsmasq controller powered by FOFA-sourced proxy IPs.

This entrypoint replaces the previous shell script. It periodically refreshes
candidate exit IPs from FOFA using the local `get_ips` module, selects the best
IP per supported service (Netflix, ChatGPT, etc.), and keeps dnsmasq configured
accordingly. Each service maintains its own priority queue with region fallbacks
so that unavailable IPs are swapped out automatically.
"""

from __future__ import annotations

import json
import logging
import os
import signal
import socket
import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Set, Tuple

from get_ips import collect_region_data


LOGGER = logging.getLogger("entrypoint")


@dataclass
class Settings:
    target_region: str
    fallback_region: Optional[str]
    fofa_key: str
    fofa_email: Optional[str]
    fofa_limit: int
    fofa_timeout: float
    fofa_workers: int
    update_interval: float
    check_interval: float
    cache_file: Path
    dnsmasq_conf: Path
    dnsmasq_bin: str
    domains_root: Path
    log_level: str
    service_names: Sequence[str]


@dataclass(order=True)
class Candidate:
    sort_key: Tuple[int, int, int]
    ip: str = field(compare=False)
    region: str = field(compare=False)
    service_score: int = field(compare=False)
    overall_score: int = field(compare=False)
    status: str = field(compare=False)
    extra: Dict[str, Any] = field(compare=False, default_factory=dict)


@dataclass
class ServiceDefinition:
    name: str
    service_key: str
    domain_files: Sequence[str]
    minimum_score: int = 1


@dataclass
class ServiceState:
    definition: ServiceDefinition
    domains: Sequence[str]
    resolved_regions: Sequence[str]
    candidates: List[Candidate] = field(default_factory=list)
    active: Optional[Candidate] = None

    def needs_refresh(self, new_regions: Sequence[str]) -> bool:
        return list(self.resolved_regions) != list(new_regions)


DEFAULT_SERVICE_DEFINITIONS: Dict[str, ServiceDefinition] = {
    "netflix": ServiceDefinition(
        name="netflix",
        service_key="netflix",
        domain_files=["netflix.txt"],
    ),
    "disney_plus": ServiceDefinition(
        name="disney_plus",
        service_key="disney_plus",
        domain_files=("disney_plus.txt",),
    ),
    "hbo_max": ServiceDefinition(
        name="hbo_max",
        service_key="hbo_max",
        domain_files=("hbo_max.txt",),
    ),
    "chatgpt": ServiceDefinition(
        name="chatgpt",
        service_key="chatgpt",
        domain_files=("chatgpt.txt",),
    ),
    "claude": ServiceDefinition(
        name="claude",
        service_key="claude",
        domain_files=("claude.txt",),
    ),
    "gemini": ServiceDefinition(
        name="gemini",
        service_key="gemini",
        domain_files=("gemini.txt",),
    ),
}


def load_settings() -> Settings:
    target_region = os.getenv("TARGET_REGION", "US").strip().upper() or "US"
    fofa_key = os.getenv("FOFA_KEY")
    if not fofa_key:
        raise SystemExit("FOFA_KEY environment variable is required")

    update_days = float(os.getenv("UPDATE_DAYS", "3"))
    if update_days <= 0:
        LOGGER.warning("UPDATE_DAYS <= 0 detected; defaulting to 1 day")
        update_days = 1.0

    check_interval = float(os.getenv("CHECK_INTERVAL", "60"))
    if check_interval <= 0:
        LOGGER.warning("CHECK_INTERVAL <= 0 detected; defaulting to 60 seconds")
        check_interval = 60.0

    fallback_region = os.getenv("FALLBACK_REGION", "").strip().upper() or None

    return Settings(
        target_region=target_region,
        fallback_region=fallback_region,
        fofa_key=fofa_key,
        fofa_email=os.getenv("FOFA_EMAIL"),
        fofa_limit=int(os.getenv("FOFA_LIMIT", "10")),
        fofa_timeout=float(os.getenv("FOFA_TIMEOUT", "8")),
        fofa_workers=int(os.getenv("FOFA_WORKERS", "8")),
        update_interval=update_days * 86400,
        check_interval=check_interval,
        cache_file=Path(os.getenv("FOFA_CACHE", "/tmp/fofa_cache.json")),
        dnsmasq_conf=Path(os.getenv("DNSMASQ_CONF", "/etc/dnsmasq.conf")),
        dnsmasq_bin=os.getenv("DNSMASQ_BIN", "dnsmasq"),
        domains_root=Path(os.getenv("DOMAINS_ROOT", Path(__file__).resolve().parent / "domains")),
        log_level=os.getenv("LOG_LEVEL", "INFO"),
        service_names=[name.strip().lower() for name in os.getenv("SERVICES", "netflix,disney_plus,hbo_max,chatgpt,claude,gemini").split(",") if name.strip()],
    )


def configure_logging(level: str) -> None:
    logging.basicConfig(
        level=getattr(logging, level.upper(), logging.INFO),
        format="%(asctime)s %(levelname)s %(name)s - %(message)s",
    )
    LOGGER.debug("Logging initialized at %s", level.upper())


def load_domains(domains_root: Path, filenames: Sequence[str]) -> List[str]:
    domains: List[str] = []
    for filename in filenames:
        path = domains_root / filename
        if not path.exists():
            LOGGER.warning("Domain file missing: %s", path)
            continue
        with path.open("r", encoding="utf-8") as f:
            for line in f:
                domain = line.strip()
                if domain and not domain.startswith("#"):
                    domains.append(domain)
    return domains


def compute_regions_to_fetch(service_states: Sequence[ServiceState]) -> List[str]:
    codes: Set[str] = set()
    for state in service_states:
        codes.update(state.resolved_regions)
    return sorted(codes)


def read_cache(cache_file: Path) -> Optional[Dict[str, Any]]:
    if not cache_file.exists():
        return None
    try:
        with cache_file.open("r", encoding="utf-8") as f:
            data = json.load(f)
        return data
    except (OSError, json.JSONDecodeError) as exc:
        LOGGER.warning("Failed to read cache %s: %s", cache_file, exc)
        return None


def write_cache(cache_file: Path, payload: Dict[str, Any]) -> None:
    try:
        tmp = cache_file.with_suffix(".tmp")
        with tmp.open("w", encoding="utf-8") as f:
            json.dump(payload, f, ensure_ascii=False, indent=2)
        tmp.replace(cache_file)
    except OSError as exc:
        LOGGER.error("Failed to write cache %s: %s", cache_file, exc)


def cache_is_fresh(cache: Dict[str, Any], max_age: float) -> bool:
    timestamp = cache.get("timestamp")
    if timestamp is None:
        return False
    return (time.time() - float(timestamp)) < max_age


def fetch_region_data(
    *,
    service_states: Sequence[ServiceState],
    settings: Settings,
) -> Dict[str, Any]:
    regions = compute_regions_to_fetch(service_states)
    LOGGER.info("Fetching FOFA data for regions: %s", ",".join(regions))
    data = collect_region_data(
        regions,
        fofa_key=settings.fofa_key,
        fofa_email=settings.fofa_email,
        limit=settings.fofa_limit,
        timeout=settings.fofa_timeout,
        workers=settings.fofa_workers,
        query_template=os.getenv("FOFA_QUERY", "body=\"Backend not available\" && country=\"{region}\""),
    )
    payload = {"timestamp": time.time(), "regions": data.get("regions", {})}
    write_cache(settings.cache_file, payload)
    return payload


def build_candidates(
    state: ServiceState,
    region_data: Dict[str, Any],
) -> List[Candidate]:
    candidates: List[Candidate] = []
    for idx, region in enumerate(state.resolved_regions):
        region_block = region_data.get(region)
        if not region_block:
            continue
        for entry in region_block.get("ips", []):
            services = entry.get("services", {})
            service_info = services.get(state.definition.service_key)
            if not service_info:
                continue
            score = int(service_info.get("score", 0))
            if score < state.definition.minimum_score:
                continue
            status = service_info.get("status", "unknown")
            if score <= 0 or status in {"blocked", "network_error"}:
                continue
            overall = int(entry.get("overall_score", score))
            sort_key = (idx, -score, -overall)
            candidates.append(
                Candidate(
                    sort_key=sort_key,
                    ip=entry.get("ip"),
                    region=region,
                    service_score=score,
                    overall_score=overall,
                    status=status,
                    extra=service_info.get("extra", {}),
                )
            )
    candidates.sort()
    LOGGER.debug(
        "Service %s assembled %d candidates", state.definition.name, len(candidates)
    )
    return candidates


def test_port80(ip: str, timeout: float = 5.0) -> bool:
    try:
        with socket.create_connection((ip, 80), timeout=timeout):
            return True
    except OSError:
        return False


def ensure_active_candidate(state: ServiceState) -> bool:
    """Ensure the service has an active, reachable candidate.

    Returns True if the active IP changed (necessitating a dnsmasq reload).
    """

    if state.active and test_port80(state.active.ip):
        return False

    for candidate in state.candidates:
        if test_port80(candidate.ip):
            if not state.active or state.active.ip != candidate.ip:
                LOGGER.info(
                    "Service %s switching to %s (region=%s score=%s status=%s)",
                    state.definition.name,
                    candidate.ip,
                    candidate.region,
                    candidate.service_score,
                    candidate.status,
                )
            state.active = candidate
            return True

    if state.active is not None:
        LOGGER.warning("Service %s lost all candidates", state.definition.name)
    state.active = None
    return True


def render_dnsmasq_config(states: Sequence[ServiceState], config_path: Path) -> bool:
    lines = [
        "domain-needed",
        "bogus-priv",
        "no-resolv",
        "no-poll",
        "all-servers",
        "server=8.8.8.8",
        "server=1.1.1.1",
        "cache-size=2048",
        "local-ttl=60",
        "interface=*",
    ]

    for state in states:
        if not state.active:
            LOGGER.debug("Service %s has no active IP; skipping dnsmasq rules", state.definition.name)
            continue
        for domain in state.domains:
            lines.append(f"address=/{domain}/{state.active.ip}")

    content = "\n".join(lines) + "\n"

    try:
        if config_path.exists():
            if config_path.read_text(encoding="utf-8") == content:
                return False
        tmp_path = config_path.with_suffix(".tmp")
        tmp_path.write_text(content, encoding="utf-8")
        tmp_path.replace(config_path)
        LOGGER.info("Updated dnsmasq configuration with %d services", len(states))
        return True
    except OSError as exc:
        LOGGER.error("Failed to write dnsmasq config %s: %s", config_path, exc)
        return False


def start_dnsmasq(config_path: Path, binary: str) -> subprocess.Popen:
    LOGGER.info("Starting dnsmasq")
    proc = subprocess.Popen([binary, "-d", "--conf-file", str(config_path)])
    return proc


def reload_dnsmasq(proc: subprocess.Popen) -> None:
    if proc.poll() is not None:
        LOGGER.error("dnsmasq is not running (exit code %s)", proc.returncode)
        return
    LOGGER.debug("Sending SIGHUP to dnsmasq for config reload")
    proc.send_signal(signal.SIGHUP)


def build_service_states(settings: Settings) -> List[ServiceState]:
    states: List[ServiceState] = []
    for name in settings.service_names:
        definition = DEFAULT_SERVICE_DEFINITIONS.get(name)
        if not definition:
            LOGGER.warning("Unknown service %s requested; skipping", name)
            continue
        domains = load_domains(settings.domains_root, definition.domain_files)
        if not domains:
            LOGGER.warning("No domains configured for service %s; skipping", name)
            continue
        resolved_regions = [settings.target_region]
        if settings.fallback_region and settings.fallback_region not in resolved_regions:
            resolved_regions.append(settings.fallback_region)
        states.append(ServiceState(definition=definition, domains=domains, resolved_regions=resolved_regions))
        LOGGER.info(
            "Service %s regions: %s",
            definition.name,
            ",".join(resolved_regions),
        )
    return states


def main() -> int:
    settings = load_settings()
    configure_logging(settings.log_level)

    service_states = build_service_states(settings)
    if not service_states:
        LOGGER.error("No valid services configured; exiting")
        return 1

    cache_data = read_cache(settings.cache_file)
    if cache_data and not cache_is_fresh(cache_data, settings.update_interval):
        cache_data = None

    if not cache_data:
        cache_data = fetch_region_data(service_states=service_states, settings=settings)

    region_data = cache_data.get("regions", {})

    # Prepare dnsmasq config from existing cache before starting dnsmasq
    for state in service_states:
        state.candidates = build_candidates(state, region_data)
        if state.candidates:
            ensure_active_candidate(state)

    render_dnsmasq_config(service_states, settings.dnsmasq_conf)
    dnsmasq_proc = start_dnsmasq(settings.dnsmasq_conf, settings.dnsmasq_bin)

    shutdown = False

    def handle_signal(signum, frame):
        nonlocal shutdown
        LOGGER.info("Received signal %s; shutting down", signum)
        shutdown = True

    signal.signal(signal.SIGTERM, handle_signal)
    signal.signal(signal.SIGINT, handle_signal)

    last_refresh = cache_data.get("timestamp", 0.0)

    try:
        while not shutdown:
            now = time.time()
            if now - last_refresh >= settings.update_interval:
                try:
                    cache_data = fetch_region_data(service_states=service_states, settings=settings)
                    region_data = cache_data.get("regions", {})
                    last_refresh = cache_data.get("timestamp", now)
                    for state in service_states:
                        state.candidates = build_candidates(state, region_data)
                except Exception:
                    LOGGER.exception("Failed to refresh FOFA data; keeping previous results")
                    last_refresh = now - settings.update_interval + settings.check_interval

            needs_reload = False
            for state in service_states:
                if not state.candidates:
                    state.candidates = build_candidates(state, region_data)
                if state.candidates:
                    if ensure_active_candidate(state):
                        needs_reload = True
                else:
                    if state.active is not None:
                        state.active = None
                        needs_reload = True

            if needs_reload:
                if render_dnsmasq_config(service_states, settings.dnsmasq_conf):
                    reload_dnsmasq(dnsmasq_proc)

            time.sleep(settings.check_interval)

    finally:
        LOGGER.info("Stopping dnsmasq")
        if dnsmasq_proc.poll() is None:
            dnsmasq_proc.terminate()
            try:
                dnsmasq_proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                dnsmasq_proc.kill()
    return 0


if __name__ == "__main__":
    sys.exit(main())
