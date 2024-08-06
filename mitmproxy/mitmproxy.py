from mitmproxy import http
import requests
import os
import time
import threading
from mitmproxy import ctx

class CustomMitmProxy:
    def __init__(self):
        self.remote_script_url = os.environ.get('REMOTE_SCRIPT_URL', '')
        self.remote_script = None
        self.update_interval = int(os.environ.get('SCRIPT_UPDATE_INTERVAL', 300))  # 默认5分钟
        self.last_update_time = 0
        self.timeout = int(os.environ.get('SCRIPT_REQUEST_TIMEOUT', 10))  # 默认10秒

        if self.remote_script_url:
            self.load_remote_script()  # 启动时立即更新远程脚本
            self.start_update_thread()

    def request(self, flow: http.HTTPFlow) -> None:
        self.handle_event(flow, 'request')

    def response(self, flow: http.HTTPFlow) -> None:
        self.handle_event(flow, 'response')

    def client_connected(self, client):
        self.handle_event(client, 'client_connected')

    def client_disconnected(self, client):
        self.handle_event(client, 'client_disconnected')

    def server_connect(self, data):
        self.handle_event(data, 'server_connect')

    def server_connected(self, data):
        self.handle_event(data, 'server_connected')

    def server_disconnected(self, data):
        self.handle_event(data, 'server_disconnected')

    def tcp_start(self, flow):
        self.handle_event(flow, 'tcp_start')

    def tcp_message(self, flow):
        self.handle_event(flow, 'tcp_message')

    def tcp_error(self, flow):
        self.handle_event(flow, 'tcp_error')

    def tcp_end(self, flow):
        self.handle_event(flow, 'tcp_end')

    def http_connect(self, flow):
        self.handle_event(flow, 'http_connect')

    def websocket_handshake(self, flow):
        self.handle_event(flow, 'websocket_handshake')

    def websocket_start(self, flow):
        self.handle_event(flow, 'websocket_start')

    def websocket_message(self, flow):
        self.handle_event(flow, 'websocket_message')

    def websocket_error(self, flow):
        self.handle_event(flow, 'websocket_error')

    def websocket_end(self, flow):
        self.handle_event(flow, 'websocket_end')

    def next_layer(self, layer):
        self.handle_event(layer, 'next_layer')

    def configure(self, updated):
        self.handle_event(updated, 'configure')

    def done(self):
        self.handle_event(None, 'done')

    def load(self, loader):
        self.handle_event(loader, 'load')

    def running(self):
        self.handle_event(None, 'running')

    def handle_event(self, flow, event_type):
        if self.remote_script_url and self.remote_script:
            self.execute_remote_script(flow, event_type)

    def load_remote_script(self):
        if self.remote_script_url:
            try:
                response = requests.get(self.remote_script_url, timeout=self.timeout)
                if response.status_code == 200:
                    self.remote_script = response.text
                    ctx.log.info("Remote script updated successfully.")
                else:
                    ctx.log.error(f"Failed to load remote script. Status code: {response.status_code}")
            except requests.exceptions.Timeout:
                ctx.log.error(f"Request to {self.remote_script_url} timed out.")
            except requests.exceptions.RequestException as e:
                ctx.log.error(f"Failed to load remote script: {e}")

    def execute_remote_script(self, flow, event_type):
        try:
            exec(self.remote_script, {'flow': flow, 'event_type': event_type})
        except Exception as e:
            ctx.log.error(f"Error executing remote script for {event_type}: {e}")

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