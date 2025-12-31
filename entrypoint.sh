#!/bin/bash

# 检查环境变量
if [ -z "$TUNNEL_TOKEN" ]; then
  echo "错误: 未设置 TUNNEL_TOKEN 环境变量。"
  exit 1
fi

# 启动 Bark 服务端并放后台
# 监听 127.0.0.1 更加安全，因为只需要 Tunnel 访问它
/usr/local/bin/bark-server --addr 127.0.0.1:8080 --data /data &

echo "Bark Server 已在后台启动..."

# 启动 Cloudflare Tunnel (作为主进程执行)
echo "正在启动 Cloudflare Tunnel..."
exec /usr/local/bin/cloudflared tunnel --no-autoupdate run --token "${TUNNEL_TOKEN}"
