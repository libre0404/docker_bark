# 阶段 1: 提取二进制文件
FROM finab/bark-server AS bark-source
FROM cloudflare/cloudflared:latest AS tunnel-source

# 阶段 2: 最终镜像
FROM debian:stable-slim

# 安装基础库和 SSL 证书
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 复制二进制文件
COPY --from=bark-source /usr/local/bin/bark-server /usr/local/bin/bark-server
COPY --from=tunnel-source /usr/local/bin/cloudflared /usr/local/bin/cloudflared

# 复制启动脚本并授权
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 持久化 Bark 数据
VOLUME /data
WORKDIR /data

# 执行启动脚本
ENTRYPOINT ["/entrypoint.sh"]
