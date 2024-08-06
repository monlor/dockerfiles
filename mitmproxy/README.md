## Environment

```
export MITMPROXY_USER=your_username
export MITMPROXY_PASS=your_password
export REMOTE_SCRIPT_URL=http://example.com/your_remote_script.py
export SCRIPT_UPDATE_INTERVAL=300  # 可选，默认为300秒
export LOG_LEVEL=error
```

## Volume

```
/home/mitmproxy/.mitmproxy
```

## Port

ui: 81

proxy: 80

## Rmote script

```
def request(flow):
    flow.request.headers["Custom-Header"] = "Custom-Value"
```