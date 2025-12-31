# 阶段 1: 提取 Bark (Alpine 版)
FROM finab/bark-server AS bark-source

# 阶段 2: 提取 Cloudflared
FROM cloudflare/cloudflared:latest AS tunnel-source

# 阶段 3: 最终运行环境 (统一使用 Alpine)
FROM alpine:latest

# 安装必要的基础库：ca-certificates(HTTPS必选), libc6-compat(兼容某些二进制), tzdata(时区)
RUN apk add --no-cache ca-certificates libc6-compat tzdata bash

# 从前两个阶段复制二进制文件
COPY --from=bark-source /usr/local/bin/bark-server /usr/local/bin/bark-server
COPY --from=tunnel-source /usr/local/bin/cloudflared /usr/local/bin/cloudflared

# 复制启动脚本并强制赋予执行权限
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chmod +x /usr/local/bin/bark-server && chmod +x /usr/local/bin/cloudflared

# 设置数据目录
RUN mkdir -p /data && chmod 777 /data
VOLUME /data
WORKDIR /data

ENTRYPOINT ["/entrypoint.sh"]
