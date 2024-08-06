def handle_event(flow, event_type):
    print(f"Event: {event_type}")

    if event_type == 'request':
        # 处理请求
        # 可以修改请求头、URL、方法等
        flow.request.headers["X-Custom-Request-Header"] = "CustomRequestValue"
        print(f"Request URL: {flow.request.url}")

    elif event_type == 'response':
        # 处理响应
        # 可以修改响应头、内容、状态码等
        flow.response.headers["X-Custom-Response-Header"] = "CustomResponseValue"
        print(f"Response status code: {flow.response.status_code}")

    elif event_type == 'client_connected':
        # 客户端连接时触发
        print(f"Client connected: {flow}")

    elif event_type == 'client_disconnected':
        # 客户端断开连接时触发
        print(f"Client disconnected: {flow}")

    elif event_type == 'server_connect':
        # 服务器连接开始时触发
        print(f"Server connecting: {flow}")

    elif event_type == 'server_connected':
        # 服务器连接建立时触发
        print(f"Server connected: {flow}")

    elif event_type == 'server_disconnected':
        # 服务器断开连接时触发
        print(f"Server disconnected: {flow}")

    elif event_type == 'tcp_start':
        # TCP连接开始时触发
        print(f"TCP connection started: {flow}")

    elif event_type == 'tcp_message':
        # 收到TCP消息时触发
        print(f"TCP message: {flow}")

    elif event_type == 'tcp_error':
        # TCP连接出错时触发
        print(f"TCP error: {flow}")

    elif event_type == 'tcp_end':
        # TCP连接结束时触发
        print(f"TCP connection ended: {flow}")

    elif event_type == 'http_connect':
        # 处理HTTP CONNECT请求
        print(f"HTTP CONNECT: {flow}")

    elif event_type == 'websocket_handshake':
        # WebSocket握手完成时触发
        print(f"WebSocket handshake: {flow}")

    elif event_type == 'websocket_start':
        # WebSocket连接开始时触发
        print(f"WebSocket started: {flow}")

    elif event_type == 'websocket_message':
        # 收到WebSocket消息时触发
        print(f"WebSocket message: {flow.websocket.messages[-1].content}")

    elif event_type == 'websocket_error':
        # WebSocket连接出错时触发
        print(f"WebSocket error: {flow}")

    elif event_type == 'websocket_end':
        # WebSocket连接结束时触发
        print(f"WebSocket ended: {flow}")

    elif event_type == 'next_layer':
        # 用于协议嗅探和动态协议切换
        print(f"Next layer: {flow}")

    elif event_type == 'configure':
        # 配置发生变化时触发
        print(f"Configuration changed: {flow}")

    elif event_type == 'done':
        # addon关闭时触发
        print("Addon is shutting down")

    elif event_type == 'load':
        # addon首次加载时触发
        print(f"Addon loaded: {flow}")

    elif event_type == 'running':
        # 代理完全启动并运行时触发
        print("Proxy is running")

    # 可以根据需要添加更多的事件处理逻辑
    # 例如，可以在这里添加日志记录、数据分析或其他自定义操作

# 主执行点
handle_event(flow, event_type)