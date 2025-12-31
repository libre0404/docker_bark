#!/bin/bash

echo "正在启动 Bark Server..."
# 使用 0.0.0.0 确保监听所有网口
/usr/local/bin/bark-server --addr 0.0.0.0:8080 --data /data &

echo "等待 Bark 启动..."
sleep 3

echo "正在启动 Cloudflare Tunnel..."
# 使用 exec 确保 cloudflared 成为 1 号进程，方便接收停止信号
exec /usr/local/bin/cloudflared tunnel --no-autoupdate run --token "${TUNNEL_TOKEN}"
