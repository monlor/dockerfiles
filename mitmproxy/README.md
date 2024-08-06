## Environment

```
export MITMPROXY_USER=your_username
export MITMPROXY_PASS=your_password
export REMOTE_SCRIPT_URL=http://example.com/your_remote_script.py
export SCRIPT_UPDATE_INTERVAL=300  # 可选，默认为300秒
```

## Volume

```
/home/mitmproxy/.mitmproxy
```

## Port

8080,8081

## Rmote script

```
def request(flow):
    flow.request.headers["Custom-Header"] = "Custom-Value"
```