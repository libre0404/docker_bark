#!/bin/bash

# 检查 Token
if [ -z "$TUNNEL_TOKEN" ]; then
  echo "Error: TUNNEL_TOKEN is not set."
  exit 1
fi

# 1. 启动 Bark Server (后台运行)
# 强制监听 127.0.0.1，确保公网无法通过 IP 直接访问 8080 端口
/usr/local/bin/bark-server -addr 127.0.0.1:8080 -data /data &
BARK_PID=$!

# 2. 启动 Cloudflare Tunnel (前台运行)
echo "Starting Cloudflare Tunnel..."
/usr/local/bin/cloudflared tunnel --no-autoupdate run --token "$TUNNEL_TOKEN" &
TUNNEL_PID=$!

# 信号捕捉：确保容器停止时优雅关闭进程
trap "kill $BARK_PID $TUNNEL_PID; exit" SIGTERM SIGINT

# 等待任一进程退出
wait -n

# 退出清理
kill $BARK_PID $TUNNEL_PID
