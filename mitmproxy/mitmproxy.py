from mitmproxy import http
import requests
import os
import time
import threading
import base64
from mitmproxy import ctx

class CustomMitmProxy:
    def __init__(self):
        self.username = os.environ.get('MITMPROXY_USER', '')
        self.password = os.environ.get('MITMPROXY_PASS', '')
        self.auth_enabled = bool(self.username)
        self.remote_script_url = os.environ.get('REMOTE_SCRIPT_URL', '')
        self.remote_script = None
        self.update_interval = int(os.environ.get('SCRIPT_UPDATE_INTERVAL', 300))  # 默认5分钟
        self.last_update_time = 0

        if self.remote_script_url:
            self.load_remote_script()  # 启动时立即更新远程脚本
            self.start_update_thread()

    def request(self, flow: http.HTTPFlow) -> None:
        if self.auth_enabled:
            if not self.authenticate(flow):
                flow.response = http.Response.make(
                    407, b"Authentication required", {"Proxy-Authenticate": "Basic"}
                )
                return

        if self.remote_script_url and self.remote_script:
            self.execute_remote_script(flow)

    def authenticate(self, flow: http.HTTPFlow) -> bool:
        auth_header = flow.request.headers.get("Proxy-Authorization")
        if auth_header:
            try:
                scheme, user_pass = auth_header.split()
                username, password = base64.b64decode(user_pass.encode()).decode().split(":")
                if username == self.username and password == self.password:
                    return True
            except Exception as e:
                ctx.log.error(f"Authentication error: {e}")
        return False

    def load_remote_script(self):
        if self.remote_script_url:
            try:
                response = requests.get(self.remote_script_url)
                if response.status_code == 200:
                    self.remote_script = response.text
                    ctx.log.info("Remote script updated successfully.")
                else:
                    ctx.log.error(f"Failed to load remote script. Status code: {response.status_code}")
            except Exception as e:
                ctx.log.error(f"Failed to load remote script: {e}")

    def execute_remote_script(self, flow):
        try:
            exec(self.remote_script, {'flow': flow})
        except Exception as e:
            ctx.log.error(f"Error executing remote script: {e}")

    def update_script_periodically(self):
        while True:
            current_time = time.time()
            if current_time - self.last_update_time >= self.update_interval:
                self.load_remote_script()
                self.last_update_time = current_time
            time.sleep(60)  # 每分钟检查一次是否需要更新

    def start_update_thread(self):
        update_thread = threading.Thread(target=self.update_script_periodically)
        update_thread.daemon = True
        update_thread.start()

addons = [CustomMitmProxy()]