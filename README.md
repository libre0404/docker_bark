# Bark + Cloudflare Tunnel 一体化安全推送方案

[![Docker Build](https://github.com/libre0404/docker_bark/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/libre0404/docker_bark/actions)

这是一个为 **ClawCloud (免费版)** 或资源受限的 VPS 专门设计的镜像。通过将 [Bark-Server](https://github.com/finab/bark-server) 与 [Cloudflare Tunnel](https://github.com/cloudflare/cloudflared) 封装在同一个 Docker 容器内，实现零端口暴露、高度隐私的 iOS 推送服务。

## 🌟 核心优势

- **突破限制**：单容器运行双进程，完美适配 ClawCloud 免费版单 Pod 限制。
- **极致安全**：Bark 仅监听 `127.0.0.1`，不暴露任何公网端口，彻底杜绝全网扫描。
- **隐私保护**：利用 Cloudflare 隧道加密传输，建议配合 Bark App 端到端加密使用。
- **自动构建**：基于 GitHub Actions，代码更新后自动推送到 GHCR 镜像仓库。

---

## 🛠️ 部署步骤

### 1. 获取 Cloudflare Tunnel Token
1. 登录 [Cloudflare Zero Trust](https://one.dash.cloudflare.com/)。
2. 导航至 `Networks` -> `Tunnels` -> `Create a Tunnel`。
3. 选择 `Cloudflared`，命名并保存。
4. 在 `Install connector` 页面选择 **Docker**，复制命令中 `--token` 后的长字符串。

### 2. 在 ClawCloud 部署
在 ClawCloud 容器管理界面中配置：

- **镜像 (Image)**: `ghcr.io/你的GitHub用户名/你的仓库名:latest`
- **环境变量 (Env)**: 
  - `TUNNEL_TOKEN`: `你刚才复制的 Token`
- **持久化挂载 (Volume)**:
  - 容器路径: `/data` (用于保存 Bark 设备 Key，防止重启后失效)

### 3. 配置域名映射
回到 Cloudflare Tunnel 网页后台，点击 `Public Hostname` -> `Add a public hostname`:
- **Subdomain**: `bark`
- **Domain**: `你的域名.com`
- **Service**: 
  - Type: `HTTP`
  - URL: `127.0.0.1:8080` (注意：必须是 127.0.0.1)

---

## 🔒 隐私安全终极配置 (推荐)

为了确保通知内容即便在服务器端也是安全的，请务必：

1. **开启端到端加密**：  
   在 iOS Bark App 中进入 `设置` -> `推送加密` -> 开启并设置 `Key`。
2. **配置 Cloudflare WAF**：  
   在 CF 防火墙设置中，仅允许你所在国家的 IP 访问 `bark.yourdomain.com`。
3. **关闭日志**：  
   本镜像默认仅输出核心运行日志，不记录推送的消息内容。

---

# 🚀 API 调用示例

部署成功后，你的推送地址为：  
`https://bark.yourdomain.com/你的DeviceKey/推送内容`

```bash
# 测试推送
curl "[https://bark.yourdomain.com/YOUR_KEY/Hello_from_ClawCloud](https://bark.yourdomain.com/YOUR_KEY/Hello_from_ClawCloud)"
```


# 🏗️ **构建说明**
本项目使用多阶段构建（Multi-stage Build）：

基础镜像：debian:stable-slim

核心组件：从官方 finab/bark-server 和 cloudflare/cloudflared 镜像中提取二进制文件。


# 📄 **开源协议**
基于 MIT 协议。Bark 服务端与 Cloudflared 归原作者所有。
