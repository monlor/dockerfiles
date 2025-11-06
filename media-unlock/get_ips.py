#!/usr/bin/env python3
"""Concurrent media unlock tester inspired by check_media.sh.

Fetch candidate proxy IPs from FOFA, probe streaming and AI services
through each IP, score their capabilities by category, and emit JSON
grouped by region that highlights which IPs unlock each service.
"""

from __future__ import annotations

import argparse
import base64
import json
import logging
import os
import re
import socket
import ssl
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from ipaddress import ip_address
from typing import Any, Callable, Dict, Iterable, List, Optional, Set, Tuple
from urllib import error, parse, request
from pathlib import Path


DEFAULT_REGIONS = ["HK"]
DEFAULT_FOFA_QUERY = 'body="Backend not available" && country="{region}"'
DEFAULT_MAX_IPS = 10
DEFAULT_TIMEOUT = 8
DEFAULT_MAX_RESPONSE = 512 * 1024  # 512 KiB
DEFAULT_WORKERS = 16

USER_AGENT = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/125.0.0.0 Safari/537.36"
)

DEFAULT_MEDIA_COOKIE_URL = "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies"
MEDIA_COOKIE_URL = os.getenv("MEDIA_COOKIE_URL", DEFAULT_MEDIA_COOKIE_URL)
MEDIA_COOKIE_LOCAL_PATH = Path(os.getenv("MEDIA_COOKIE_LOCAL", Path(__file__).resolve().parent / "data" / "media_cookies.txt"))


_media_cookie_lines: Optional[List[str]] = None

LOGGER = logging.getLogger("get_ips")


class HTTPRequestError(RuntimeError):
    """Raised when a low-level HTTPS request fails."""


@dataclass
class ServiceResult:
    status: str
    detail: Optional[str] = None
    extra: Optional[Dict[str, Any]] = None


@dataclass(frozen=True)
class ServiceProfile:
    category: str
    checker: Callable[[str, float], ServiceResult]
    score_map: Dict[str, int]
    full_statuses: Set[str]
    partial_statuses: Set[str]
    blocked_statuses: Set[str]
    error_statuses: Set[str]
    default_score: int = 0


def get_media_cookie_lines() -> List[str]:
    global _media_cookie_lines
    if _media_cookie_lines is None:
        content: Optional[str] = None
        if MEDIA_COOKIE_URL:
            try:
                with request.urlopen(MEDIA_COOKIE_URL, timeout=DEFAULT_TIMEOUT) as resp:
                    content = resp.read().decode("utf-8")
                    LOGGER.debug("Loaded media cookies from remote URL %s", MEDIA_COOKIE_URL)
            except Exception as exc:  # pragma: no cover - network failure
                LOGGER.warning("Remote MEDIA_COOKIE_URL fetch failed: %s", exc)
        if content is None and MEDIA_COOKIE_LOCAL_PATH.exists():
            try:
                content = MEDIA_COOKIE_LOCAL_PATH.read_text(encoding="utf-8")
                LOGGER.debug("Loaded media cookies from local path %s", MEDIA_COOKIE_LOCAL_PATH)
            except OSError as exc:
                raise HTTPRequestError(f"Unable to read local Disney cookie data: {exc}") from exc
        if content is None:
            raise HTTPRequestError("Unable to load Disney cookie data from remote or local sources")
        _media_cookie_lines = content.splitlines()
    return _media_cookie_lines


def fetch_fofa_ips(
    *,
    region: str,
    count: int,
    key: str,
    email: Optional[str],
    query_template: str,
) -> List[str]:
    """Query FOFA for candidate IPs for a region."""

    LOGGER.debug("Querying FOFA: region=%s limit=%d query=%s", region, count, query_template)
    query = query_template.format(region=region.upper())
    qbase64 = base64.b64encode(query.encode("utf-8")).decode("ascii")

    params = {"size": str(count), "qbase64": qbase64}
    if email:
        params["email"] = email
    params["key"] = key

    url = f"https://fofa.info/api/v1/search/all?{parse.urlencode(params)}"
    req = request.Request(url, headers={"User-Agent": USER_AGENT})

    try:
        with request.urlopen(req, timeout=DEFAULT_TIMEOUT) as resp:
            payload = resp.read()
    except error.HTTPError as exc:  # pragma: no cover - network failure
        raise RuntimeError(f"FOFA HTTP error {exc.code}: {exc.reason}") from exc
    except error.URLError as exc:  # pragma: no cover - network failure
        raise RuntimeError(f"Unable to reach FOFA: {exc.reason}") from exc

    data = json.loads(payload.decode("utf-8"))
    results = data.get("results", [])
    ips = [item[0] for item in results if item and isinstance(item, list)]
    LOGGER.info("FOFA returned %d IPs for region=%s", len(ips), region)
    return ips


def is_valid_ip(value: str) -> bool:
    try:
        ip_address(value)
        return True
    except ValueError:
        return False


def request_through_ip(
    *,
    ip: str,
    host: str,
    path: str,
    method: str = "GET",
    headers: Optional[Dict[str, str]] = None,
    timeout: float = DEFAULT_TIMEOUT,
    body: Optional[bytes] = None,
    max_bytes: int = DEFAULT_MAX_RESPONSE,
) -> Tuple[int, Dict[str, str], str]:
    """Perform an HTTPS request to host using the supplied IP (SNI preserved)."""

    if not path.startswith("/"):
        path = "/" + path

    default_headers = {
        "Host": host,
        "User-Agent": USER_AGENT,
        "Accept": "*/*",
        "Accept-Language": "en-US,en;q=0.9",
        "Accept-Encoding": "identity",
        "Connection": "close",
    }
    if headers:
        default_headers.update(headers)

    if body is None:
        request_head = (
            f"{method} {path} HTTP/1.1\r\n"
            + "\r\n".join(f"{k}: {v}" for k, v in default_headers.items())
            + "\r\n\r\n"
        )
        request_bytes = request_head.encode("utf-8")
    else:
        default_headers["Content-Length"] = str(len(body))
        request_head = (
            f"{method} {path} HTTP/1.1\r\n"
            + "\r\n".join(f"{k}: {v}" for k, v in default_headers.items())
            + "\r\n\r\n"
        )
        request_bytes = request_head.encode("utf-8") + body

    context = ssl.create_default_context()

    try:
        with socket.create_connection((ip, 443), timeout=timeout) as sock:
            with context.wrap_socket(sock, server_hostname=host) as tls:
                tls.sendall(request_bytes)

                buffer = bytearray()
                while True:
                    chunk = tls.recv(4096)
                    if not chunk:
                        break
                    buffer.extend(chunk)
                    if len(buffer) >= max_bytes:
                        break
    except (socket.timeout, socket.error, ssl.SSLError) as exc:
        raise HTTPRequestError(str(exc)) from exc

    raw = bytes(buffer)
    header_blob, _, body_blob = raw.partition(b"\r\n\r\n")
    header_lines = header_blob.split(b"\r\n")
    if not header_lines:
        raise HTTPRequestError("Empty response")

    status_line = header_lines[0].decode("iso-8859-1", errors="replace")
    match = re.match(r"HTTP/\d\.\d\s+(\d{3})", status_line)
    if not match:
        raise HTTPRequestError(f"Malformed status line: {status_line!r}")
    status_code = int(match.group(1))

    header_dict: Dict[str, str] = {}
    for line in header_lines[1:]:
        if b":" not in line:
            continue
        key, value = line.split(b":", 1)
        header_dict[key.decode("iso-8859-1").strip().lower()] = (
            value.decode("iso-8859-1").strip()
        )

    if header_dict.get("transfer-encoding", "").lower() == "chunked":
        body_blob = _decode_chunked(body_blob)

    body_text = body_blob.decode("utf-8", errors="ignore")
    return status_code, header_dict, body_text


def _decode_chunked(body: bytes) -> bytes:
    output = bytearray()
    idx = 0
    while idx < len(body):
        line_end = body.find(b"\r\n", idx)
        if line_end == -1:
            break
        chunk_header = body[idx:line_end]
        try:
            chunk_size = int(chunk_header.split(b";", 1)[0] or b"0", 16)
        except ValueError:
            break
        idx = line_end + 2
        if chunk_size == 0:
            break
        output.extend(body[idx : idx + chunk_size])
        idx += chunk_size + 2
    return bytes(output)


def check_netflix(ip: str, timeout: float) -> ServiceResult:
    def request_with_redirect(target_path: str) -> Tuple[int, Dict[str, str], str]:
        host = "www.netflix.com"
        path_to_use = target_path
        for _ in range(4):
            code, headers, body = request_through_ip(
                ip=ip,
                host=host,
                path=path_to_use,
                timeout=timeout,
            )
            if code not in {301, 302, 303, 307, 308}:
                return code, headers, body
            location = headers.get("location")
            if not location:
                return code, headers, body
            parsed = parse.urlparse(location)
            if parsed.netloc and parsed.netloc != host:
                return code, headers, body
            new_path = parsed.path or path_to_use
            if parsed.query:
                new_path = f"{new_path}?{parsed.query}"
            path_to_use = new_path
        return code, headers, body

    codes: List[Optional[int]] = []
    last_body = ""
    for path in ("/title/81280792", "/title/70143836"):
        try:
            code, _, body = request_with_redirect(path)
            codes.append(code)
            last_body = body or last_body
        except HTTPRequestError as exc:
            return ServiceResult("network_error", detail=str(exc), extra={"codes": str(codes)})

    if all(code == 404 for code in codes):
        return ServiceResult("originals_only", extra={"codes": str(codes)})
    if any(code == 403 for code in codes):
        return ServiceResult("blocked", extra={"codes": str(codes)})
    if any(code == 200 for code in codes):
        try:
            _, _, homepage = request_with_redirect("/")
        except HTTPRequestError:
            homepage = last_body
        match = re.search(r"data-country=\"([A-Z]{2})\"", homepage or "")
        region = match.group(1) if match else None
        extra = {"codes": str(codes)}
        if region:
            extra["region"] = region
        return ServiceResult("full", extra=extra)

    return ServiceResult("unknown", extra={"codes": str(codes)})


def check_chatgpt(ip: str, timeout: float) -> ServiceResult:
    try:
        _, _, body_api = request_through_ip(
            ip=ip,
            host="api.openai.com",
            path="/compliance/cookie_requirements",
            timeout=timeout,
            headers={
                "Authorization": "Bearer null",
                "Origin": "https://platform.openai.com",
                "Referer": "https://platform.openai.com/",
                "Sec-Fetch-Site": "same-site",
                "Sec-Fetch-Mode": "cors",
                "Sec-Fetch-Dest": "empty",
            },
        )
    except HTTPRequestError as exc:
        return ServiceResult("network_error", detail=str(exc))

    try:
        _, _, body_ios = request_through_ip(
            ip=ip,
            host="ios.chat.openai.com",
            path="/",
            timeout=timeout,
            headers={"Upgrade-Insecure-Requests": "1"},
        )
    except HTTPRequestError as exc:
        return ServiceResult("network_error", detail=str(exc))

    blocked_api = "unsupported_country" in body_api.lower()
    blocked_ios = "vpn" in body_ios.lower()

    if not blocked_api and not blocked_ios:
        return ServiceResult("full")
    if blocked_api and blocked_ios:
        return ServiceResult("blocked")
    if not blocked_api and blocked_ios:
        return ServiceResult("web_only")
    if blocked_api and not blocked_ios:
        return ServiceResult("mobile_only")
    return ServiceResult("unknown")


def check_claude(ip: str, timeout: float) -> ServiceResult:
    try:
        code, headers, _ = request_through_ip(
            ip=ip,
            host="claude.ai",
            path="/",
            timeout=timeout,
        )
    except HTTPRequestError as exc:
        return ServiceResult("network_error", detail=str(exc))

    location = headers.get("location", "") if headers else ""

    if code in {200}:
        return ServiceResult("full", extra={"code": str(code)})
    if code in {301, 302, 307, 308}:
        if "app-unavailable-in-region" in location:
            return ServiceResult("blocked", extra={"code": str(code), "location": location})
        if location:
            return ServiceResult("full", extra={"code": str(code), "location": location})
        return ServiceResult("full", extra={"code": str(code)})
    if code in {401, 403, 451}:
        return ServiceResult("blocked", extra={"code": str(code)})
    if 400 <= code < 500:
        return ServiceResult("blocked", extra={"code": str(code)})
    if code >= 500:
        return ServiceResult("service_error", extra={"code": str(code)})
    return ServiceResult("unknown", extra={"code": str(code)})


DISNEY_DEVICE_PAYLOAD = (
    '{"deviceFamily":"browser","applicationRuntime":"chrome","deviceProfile":"windows","attributes":{}}'
)


def check_disney_plus(ip: str, timeout: float) -> ServiceResult:
    try:
        cookie_lines = get_media_cookie_lines()
    except HTTPRequestError as exc:
        return ServiceResult("config_error", detail=str(exc))

    if len(cookie_lines) < 8:
        return ServiceResult("config_error", detail="MEDIA_COOKIE content is incomplete")

    auth_line = cookie_lines[1].strip().strip("'")
    if ":" not in auth_line:
        return ServiceResult("config_error", detail="Authorization header missing")
    _, auth_value = auth_line.split(":", 1)
    auth_value = auth_value.strip()
    bearer_auth = auth_value
    raw_auth = bearer_auth.replace("Bearer ", "", 1) if bearer_auth.startswith("Bearer ") else bearer_auth

    pre_cookie = cookie_lines[0]
    graphql_template = cookie_lines[7]

    try:
        _, _, device_body = request_through_ip(
            ip=ip,
            host="disney.api.edge.bamgrid.com",
            path="/devices",
            method="POST",
            timeout=timeout,
            headers={
                "Authorization": bearer_auth,
                "Content-Type": "application/json; charset=UTF-8",
            },
            body=DISNEY_DEVICE_PAYLOAD.encode("utf-8"),
        )
    except HTTPRequestError as exc:
        return ServiceResult("network_error", detail=str(exc))

    if "403 ERROR" in device_body.upper():
        return ServiceResult("blocked", extra={"stage": "device"})

    assertion_match = re.search(r'"assertion"\s*:\s*"([^"]+)"', device_body)
    if not assertion_match:
        return ServiceResult("token_error", detail="Missing assertion")

    assertion = assertion_match.group(1)
    token_form = pre_cookie.replace("DISNEYASSERTION", assertion)

    try:
        _, _, token_body = request_through_ip(
            ip=ip,
            host="disney.api.edge.bamgrid.com",
            path="/token",
            method="POST",
            timeout=timeout,
            headers={
                "Authorization": bearer_auth,
                "Content-Type": "application/x-www-form-urlencoded",
            },
            body=token_form.encode("utf-8"),
        )
    except HTTPRequestError as exc:
        return ServiceResult("network_error", detail=str(exc))

    lowered_token = token_body.lower()
    if "forbidden-location" in lowered_token or "403 error" in lowered_token:
        return ServiceResult("blocked", extra={"stage": "token"})

    refresh_match = re.search(r'"refresh_token"\s*:\s*"([^"]+)"', token_body)
    if not refresh_match:
        return ServiceResult("token_error", detail="Missing refresh token")

    refresh_token = refresh_match.group(1)
    graphql_body = graphql_template.replace("ILOVEDISNEY", refresh_token)

    try:
        _, _, graphql_response = request_through_ip(
            ip=ip,
            host="disney.api.edge.bamgrid.com",
            path="/graph/v1/device/graphql",
            method="POST",
            timeout=timeout,
            headers={
                "Authorization": raw_auth,
                "Content-Type": "application/json",
            },
            body=graphql_body.encode("utf-8"),
        )
    except HTTPRequestError as exc:
        return ServiceResult("network_error", detail=str(exc))

    region_match = re.search(r'"countryCode"\s*:\s*"([A-Z]{2})"', graphql_response)
    support_match = re.search(r'"inSupportedLocation"\s*:\s*(true|false)', graphql_response)

    preview_status = "unknown"
    try:
        preview_code, preview_headers, preview_body = request_through_ip(
            ip=ip,
            host="www.disneyplus.com",
            path="/",
            timeout=timeout,
        )
    except HTTPRequestError:
        preview_code = None
        preview_headers = {}
        preview_body = ""

    location = preview_headers.get("location", "")
    preview_text = (preview_body or "") + location
    if "preview" in preview_text.lower() or "unavailable" in preview_text.lower():
        preview_status = "preview"

    region = region_match.group(1) if region_match else None
    in_supported = support_match.group(1).lower() == "true" if support_match else None

    extra: Dict[str, Any] = {}
    if region:
        extra["region"] = region
    if in_supported is not None:
        extra["supported"] = in_supported
    if preview_code is not None:
        extra["preview_http"] = preview_code
    if preview_status == "preview":
        extra["preview"] = True
        if location:
            extra["preview_location"] = location

    if not region:
        return ServiceResult("no_region", extra=extra)
    if preview_status == "preview":
        return ServiceResult("preview_only", extra=extra)
    if in_supported is False:
        return ServiceResult("coming_soon", extra=extra)
    if in_supported is True or region == "JP":
        return ServiceResult("full", extra=extra)

    return ServiceResult("unknown", extra=extra)


def check_hbo_max(ip: str, timeout: float) -> ServiceResult:
    try:
        code, _, body = request_through_ip(
            ip=ip,
            host="www.max.com",
            path="/",
            timeout=timeout,
        )
    except HTTPRequestError as exc:
        return ServiceResult("network_error", detail=str(exc))

    if not body:
        return ServiceResult("unknown", extra={"code": code})

    region_match = re.search(r'countryCode=([A-Z]{2})', body)
    available_regions = {match.upper() for match in re.findall(r'"url":"/([a-z]{2})/[a-z]{2}"', body)}
    available_regions.add("US")

    extra = {"code": code}
    if region_match:
        region = region_match.group(1).upper()
        extra["region"] = region
    else:
        region = None

    if not region:
        return ServiceResult("unknown", extra=extra)
    if available_regions and region in available_regions:
        return ServiceResult("full", extra=extra)
    return ServiceResult("blocked", extra=extra)


def check_gemini(ip: str, timeout: float) -> ServiceResult:
    try:
        _, _, body = request_through_ip(
            ip=ip,
            host="gemini.google.com",
            path="/",
            timeout=timeout,
        )
    except HTTPRequestError as exc:
        return ServiceResult("network_error", detail=str(exc))

    allows = "45631641,null,true" in body
    region_match = re.search(r',2,1,200,"([A-Z]{3})"', body)
    extra: Dict[str, Any] = {}
    if region_match:
        extra["region"] = region_match.group(1)

    if allows:
        return ServiceResult("full", extra=extra)
    if "vpn" in body.lower() or "restricted" in body.lower():
        return ServiceResult("blocked", extra=extra)
    return ServiceResult("blocked", extra=extra)


def check_meta_ai(ip: str, timeout: float) -> ServiceResult:
    try:
        _, _, body = request_through_ip(
            ip=ip,
            host="www.meta.ai",
            path="/",
            timeout=timeout,
            headers={
                "Accept": "*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
                "Upgrade-Insecure-Requests": "1",
            },
        )
    except HTTPRequestError as exc:
        return ServiceResult("network_error", detail=str(exc))

    if not body:
        return ServiceResult("page_error")

    lowered = body.lower()
    if "abrageoblockederrorroot" in lowered:
        return ServiceResult("blocked")
    if "kadabrarootcontainer" in lowered:
        region_match = re.search(r'"code"\s*:\s*"([A-Z]+_[A-Z0-9]+)"', body)
        region = None
        if region_match:
            token = region_match.group(1)
            parts = token.split("_")
            if len(parts) > 1:
                region = parts[-1]
        extra = {"token": region_match.group(1)} if region_match else {}
        if region:
            extra["region"] = region
        return ServiceResult("full", extra=extra)
    return ServiceResult("page_error")


def check_bing(ip: str, timeout: float) -> ServiceResult:
    try:
        _, _, body = request_through_ip(
            ip=ip,
            host="www.bing.com",
            path="/search?q=curl",
            timeout=timeout,
        )
    except HTTPRequestError as exc:
        return ServiceResult("network_error", detail=str(exc))

    if not body:
        return ServiceResult("page_error")

    if "cn.bing.com" in body:
        return ServiceResult("cn", extra={"region": "CN"})

    region_match = re.search(r'Region\s*:\s*"([A-Z]{2})"', body)
    region = region_match.group(1) if region_match else None

    if 'sj_cook.set("SRCHHPGUSR","HV"' in body:
        return ServiceResult("risky", extra={"region": region})

    if region:
        return ServiceResult("full", extra={"region": region})

    return ServiceResult("unknown")


SERVICE_PROFILES: Dict[str, ServiceProfile] = {
    "netflix": ServiceProfile(
        category="streaming",
        checker=check_netflix,
        score_map={
            "full": 100,
            "originals_only": 60,
            "blocked": 0,
        },
        full_statuses=frozenset({"full"}),
        partial_statuses=frozenset({"originals_only"}),
        blocked_statuses=frozenset({"blocked"}),
        error_statuses=frozenset({"network_error"}),
        default_score=0,
    ),
    "disney_plus": ServiceProfile(
        category="streaming",
        checker=check_disney_plus,
        score_map={
            "full": 100,
            "coming_soon": 60,
            "preview_only": 40,
        },
        full_statuses=frozenset({"full"}),
        partial_statuses=frozenset({"coming_soon", "preview_only"}),
        blocked_statuses=frozenset({"blocked", "no_region"}),
        error_statuses=frozenset({"network_error", "token_error", "config_error"}),
        default_score=0,
    ),
    "hbo_max": ServiceProfile(
        category="streaming",
        checker=check_hbo_max,
        score_map={
            "full": 100,
            "blocked": 0,
        },
        full_statuses=frozenset({"full"}),
        partial_statuses=frozenset(),
        blocked_statuses=frozenset({"blocked"}),
        error_statuses=frozenset({"network_error"}),
        default_score=0,
    ),
    "chatgpt": ServiceProfile(
        category="ai",
        checker=check_chatgpt,
        score_map={
            "full": 100,
            "web_only": 70,
            "mobile_only": 70,
            "blocked": 0,
        },
        full_statuses=frozenset({"full"}),
        partial_statuses=frozenset({"web_only", "mobile_only"}),
        blocked_statuses=frozenset({"blocked"}),
        error_statuses=frozenset({"network_error"}),
        default_score=0,
    ),
    "claude": ServiceProfile(
        category="ai",
        checker=check_claude,
        score_map={
            "full": 100,
            "blocked": 0,
            "service_error": 0,
        },
        full_statuses=frozenset({"full"}),
        partial_statuses=frozenset(),
        blocked_statuses=frozenset({"blocked"}),
        error_statuses=frozenset({"network_error", "service_error"}),
        default_score=0,
    ),
    "meta_ai": ServiceProfile(
        category="ai",
        checker=check_meta_ai,
        score_map={
            "full": 100,
            "page_error": 0,
            "blocked": 0,
        },
        full_statuses=frozenset({"full"}),
        partial_statuses=frozenset(),
        blocked_statuses=frozenset({"blocked"}),
        error_statuses=frozenset({"network_error", "page_error"}),
        default_score=0,
    ),
    "gemini": ServiceProfile(
        category="ai",
        checker=check_gemini,
        score_map={
            "full": 100,
            "blocked": 0,
        },
        full_statuses=frozenset({"full"}),
        partial_statuses=frozenset(),
        blocked_statuses=frozenset({"blocked"}),
        error_statuses=frozenset({"network_error"}),
        default_score=0,
    ),
    "bing": ServiceProfile(
        category="web",
        checker=check_bing,
        score_map={
            "full": 100,
            "risky": 60,
            "cn": 30,
            "blocked": 0,
        },
        full_statuses=frozenset({"full"}),
        partial_statuses=frozenset({"risky", "cn"}),
        blocked_statuses=frozenset({"blocked"}),
        error_statuses=frozenset({"network_error", "page_error"}),
        default_score=0,
    ),
}


def evaluate_ip(region: str, ip: str, timeout: float) -> Optional[Dict[str, object]]:
    LOGGER.debug("Evaluating IP: region=%s ip=%s", region, ip)
    results: Dict[str, ServiceResult] = {}

    for name, profile in SERVICE_PROFILES.items():
        results[name] = profile.checker(ip, timeout)

    if all(res.status == "network_error" for res in results.values()):
        LOGGER.warning("Skipping IP: region=%s ip=%s (all services network_error)", region, ip)
        return None

    service_details: Dict[str, Dict[str, Any]] = {}
    category_scores: Dict[str, List[int]] = {}

    for name, result in results.items():
        profile = SERVICE_PROFILES[name]
        score = profile.score_map.get(result.status, profile.default_score)
        detail: Dict[str, Any] = {
            "status": result.status,
            "score": score,
            "category": profile.category,
        }
        if result.detail:
            detail["detail"] = result.detail
        if result.extra:
            detail["extra"] = result.extra
        service_details[name] = detail
        category_scores.setdefault(profile.category, []).append(score)
        LOGGER.debug(
            "Service result: region=%s ip=%s service=%s status=%s score=%s info=%s",
            region,
            ip,
            name,
            result.status,
            score,
            result.extra or result.detail,
        )

    category_summary = {
        category: {
            "score": int(round(sum(values) / len(values))) if values else 0,
            "services": sorted(
                name for name, detail in service_details.items() if detail["category"] == category
            ),
        }
        for category, values in category_scores.items()
    }

    if not category_summary:
        LOGGER.warning("No service data collected: region=%s ip=%s", region, ip)
        return None

    overall_score = int(round(sum(item["score"] for item in category_summary.values()) / len(category_summary)))

    LOGGER.info(
        "Completed IP evaluation: region=%s ip=%s overall=%s categories=%s",
        region,
        ip,
        overall_score,
        {
            category: summary["score"]
            for category, summary in category_summary.items()
        },
    )

    return {
        "ip": ip,
        "region": region,
        "overall_score": overall_score,
        "categories": category_summary,
        "services": service_details,
    }


def evaluate_region(
    *,
    region: str,
    ips: Iterable[str],
    timeout: float,
    executor: ThreadPoolExecutor,
) -> List[Dict[str, object]]:
    ips = list(ips)
    LOGGER.info("Evaluating region=%s with %d IP candidates", region, len(ips))
    futures = {
        executor.submit(evaluate_ip, region, ip, timeout): ip
        for ip in ips
    }
    output: List[Dict[str, object]] = []
    for future in as_completed(futures):
        result = future.result()
        if result:
            output.append(result)
    LOGGER.info("Region=%s evaluation complete with %d usable IPs", region, len(output))
    return output


def classify_service_status(profile: ServiceProfile, status: str) -> str:
    if status in profile.full_statuses:
        return "full_support"
    if status in profile.partial_statuses:
        return "partial_support"
    if status in profile.blocked_statuses:
        return "blocked"
    if status in profile.error_statuses:
        return "errors"
    return "other"


def aggregate_services(ip_entries: Iterable[Dict[str, Any]]) -> Dict[str, Dict[str, Any]]:
    summary: Dict[str, Dict[str, Any]] = {}
    for ip_info in ip_entries:
        ip_addr = ip_info.get("ip")
        services = ip_info.get("services", {})
        for name, detail in services.items():
            profile = SERVICE_PROFILES.get(name)
            if not profile:
                continue
            bucket = classify_service_status(profile, detail.get("status", "unknown"))
            service_summary = summary.setdefault(
                name,
                {
                    "category": profile.category,
                    "full_support": [],
                    "partial_support": [],
                    "blocked": [],
                    "errors": [],
                    "other": [],
                },
            )
            if bucket == "full_support":
                service_summary["full_support"].append(ip_addr)
            elif bucket == "partial_support":
                service_summary["partial_support"].append(ip_addr)
            elif bucket == "blocked":
                service_summary["blocked"].append(ip_addr)
            elif bucket == "errors":
                service_summary["errors"].append(ip_addr)
            else:
                service_summary["other"].append({"ip": ip_addr, "status": detail.get("status", "unknown")})
    for service_summary in summary.values():
        service_summary["full_support"].sort()
        service_summary["partial_support"].sort()
        service_summary["blocked"].sort()
        service_summary["errors"].sort()
        service_summary["other"] = sorted(
            service_summary["other"], key=lambda item: (item.get("status"), item.get("ip"))
        )
    return summary


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "regions",
        nargs="*",
        default=DEFAULT_REGIONS,
        help="Region codes to query (default: %(default)s)",
    )
    parser.add_argument(
        "--fofa-key",
        dest="fofa_key",
        default=os.getenv("FOFA_KEY"),
        help="FOFA API key (env: FOFA_KEY)",
    )
    parser.add_argument(
        "--fofa-email",
        dest="fofa_email",
        default=os.getenv("FOFA_EMAIL"),
        help="FOFA account email (env: FOFA_EMAIL)",
    )
    parser.add_argument(
        "--query",
        dest="query_template",
        default=DEFAULT_FOFA_QUERY,
        help="FOFA query template with {region} placeholder",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=DEFAULT_MAX_IPS,
        help="Maximum IPs per region (default: %(default)s)",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=DEFAULT_TIMEOUT,
        help="Timeout per probe in seconds (default: %(default)s)",
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=DEFAULT_WORKERS,
        help="Thread pool size for concurrent probes (default: %(default)s)",
    )
    parser.add_argument(
        "--pretty",
        action="store_true",
        help="Pretty-print JSON output",
    )
    parser.add_argument(
        "--log-level",
        default=os.getenv("GET_IPS_LOG_LEVEL", "INFO"),
        choices=["CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG"],
        help="Set logging level (default: %(default)s)",
    )
    return parser.parse_args(argv)


def collect_region_data(
    regions: Iterable[str],
    *,
    fofa_key: str,
    fofa_email: Optional[str],
    limit: int,
    timeout: float,
    workers: int,
    query_template: str,
) -> Dict[str, Any]:
    region_map: Dict[str, List[Dict[str, Any]]] = {}

    with ThreadPoolExecutor(max_workers=workers) as executor:
        for region in regions:
            region_code = region.upper()
            ips = fetch_fofa_ips(
                region=region_code,
                count=limit,
                key=fofa_key,
                email=fofa_email,
                query_template=query_template,
            )
            valid_ips = [ip for ip in ips if is_valid_ip(ip)]
            if not valid_ips:
                continue
            region_results = evaluate_region(
                region=region_code,
                ips=valid_ips,
                timeout=timeout,
                executor=executor,
            )
            if region_results:
                region_map.setdefault(region_code, []).extend(region_results)

    output_data: Dict[str, Any] = {"regions": {}}
    for region_code, ip_entries in region_map.items():
        ip_entries.sort(key=lambda item: (-item["overall_score"], item["ip"]))
        service_summary = aggregate_services(ip_entries)
        output_data["regions"][region_code] = {
            "ips": ip_entries,
            "services": service_summary,
        }

    return output_data


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)

    logging.basicConfig(
        level=getattr(logging, args.log_level.upper(), logging.INFO),
        format="%(asctime)s %(levelname)s %(message)s",
    )
    LOGGER.debug("Logger initialized at level=%s", args.log_level)

    if not args.fofa_key:
        print("FOFA key is required via --fofa-key or FOFA_KEY env", file=sys.stderr)
        return 2

    output_data = collect_region_data(
        args.regions,
        fofa_key=args.fofa_key,
        fofa_email=args.fofa_email,
        limit=args.limit,
        timeout=args.timeout,
        workers=args.workers,
        query_template=args.query_template,
    )

    if args.pretty:
        print(json.dumps(output_data, ensure_ascii=False, indent=2))
    else:
        print(json.dumps(output_data, ensure_ascii=False))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
