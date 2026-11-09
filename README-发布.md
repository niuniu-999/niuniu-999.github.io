# 发布指南（CTF Garden）

站点源码就是这个 Obsidian 仓库，Quartz 5 负责把 `content/` 渲染成静态站。

## 1. 写笔记

- 笔记放在 `content/` 下面（现有两个目录：`CTF-Writeups/`、`Study-Notes/`，可以自己新建子目录）。
- **放进 `content/` 就会被发布**；不想公开的东西放在 `content/` 之外，或放到 `content/private/`（已在 `ignorePatterns` 里排除）。
- 单篇不想出现在列表/搜索里，可以在 frontmatter 里写 `unlisted: true`。
- 推荐 frontmatter：

```yaml
---
title: 标题
description: 一句话摘要（会出现在列表和分享卡片里）
tags:
  - ctf
  - web
---
```

- 图片直接粘进 Obsidian，落到 `content/assets/`，会自动 slug 成 `pasted-image-*.png` 并正确引用。
- 越简单的 Obsidian 语法越稳：`#标题`、`**加粗**`、`- 列表`、`> 引用`、```` ``` ```` 代码块、`[[双链]]`、`![[图片]]`。`dataview` / 部分插件语法不会渲染。

## 2. 发布到 GitHub Pages（现用，地址 https://niuniu-999.github.io/）

```powershell
cd C:\Users\32948\Desktop\ctf
.\publish.ps1                 # 构建 + 提交 + 推送
.\publish.ps1 -Message "add reverse notes"
.\publish.ps1 -SkipBuild      # 只提交推送，不重新构建
```

`publish.ps1` 先试 `git push`；如果 github.com 连不上（本机常见），自动改走 GitHub REST API 提交 blob/tree/commit/ref，效果一样，之后 GitHub Actions 会自动构建部署（约 40 秒）。

推送后本地与远端的 commit 哈希会不同（API 路径下 GitHub 会重写提交时间），内容树完全一致。想对齐本地历史：

```powershell
git fetch origin
git reset --hard origin/main
```

## 3. 国内访问方案

现在 https://niuniu-999.github.io/ 实测 0.5s 打开（静态资源已全部自托管，没有 Google Fonts 之类的墙外依赖）。如果某些地区还是慢，按下面任选一个做镜像：

### A. Cloudflare Pages（免费、不用备案，`*.pages.dev` 国内基本可直连）

一次性：注册 https://dash.cloudflare.com → My Profile → API Tokens → 建 token（权限 `Account > Cloudflare Pages > Edit`）→ 记下 Account ID。

```powershell
$env:CLOUDFLARE_API_TOKEN  = "你的token"
$env:CLOUDFLARE_ACCOUNT_ID = "你的account-id"
.\deploy-cf.ps1
```

产出 `https://ctf-garden.pages.dev`，之后每次改完笔记跑一次 `.\deploy-cf.ps1` 即可同步。

### B. 腾讯云 EdgeOne Pages（国内节点最快，需实名）

1. https://edgeone.ai/ 用腾讯云账号登录 → Pages → 新建项目
2. 选「直接上传」，把本地 `public\` 整个目录拖进去
3. 得到 `https://xxx.edgeone.app` 域名，国内解析到国内节点
4. 每次改完笔记：本地 `.\publish.ps1 -SkipBuild` 之前先 `node ./quartz/bootstrap-cli.mjs build`，再重新上传 `public\`

### C. Gitee 镜像（国内备份代码，clone/pull 快）

```powershell
git remote add gitee https://gitee.com/你的用户名/ctf-garden.git
git push gitee main
```

（Gitee 免费版 Pages 已停止新开通，所以这里只当代码备份/协作源，不做站点托管。）

## 4. 目录速查

- `content/` 笔记源文件
- `public/` 构建产物（自动生成，不要手改）
- `quartz.config.yaml` 站点配置：标题、语言、字体、插件
- `.github/workflows/deploy.yml` 推送 main 后自动构建部署
- `publish.ps1` 一键发布（GitHub）
- `deploy-cf.ps1` 一键发布（Cloudflare Pages）
