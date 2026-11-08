# CTF Garden 🌱

基于 [Quartz 5](https://quartz.jzhao.xyz) 的数字花园，用于存放 CTF Writeup 和学习笔记。

## 目录结构

```
ctf/
├── content/              # ← 你的所有笔记都在这里写
│   ├── index.md          # 主页
│   ├── CTF-Writeups/     # CTF 比赛 WP
│   ├── Study-Notes/      # 学习笔记
│   └── assets/           # 图片等附件
├── quartz.config.yaml    # 站点配置（标题/主题/插件）
└── .github/workflows/    # 自动部署
```

## 日常写作

1. 用 Obsidian 打开本目录作为 vault
2. 在 `content/` 下新建 `.md` 文件
3. **想公开的笔记**，开头加 frontmatter：

   ```yaml
   ---
   publish: true
   title: 我的 WP 标题
   tags: [web, misc]
   ---
   ```

4. **不想公开的笔记**，不要加 `publish: true`，或者放到 `content/private/` 目录（整个目录已被忽略）
5. 图片粘贴到 `content/assets/` 下

## 本地预览

```powershell
npm install        # 首次需要
npx quartz build --serve
```

浏览器打开 http://localhost:8080 预览。

## 部署到 GitHub Pages

### 首次设置

1. 在 GitHub 新建一个仓库，命名为 `<你的用户名>.github.io`（例如 `zhangsan.github.io`）
2. 在仓库 Settings → Pages → Source 选择 **GitHub Actions**
3. 把本目录推送到 main 分支：

   ```powershell
   git add .
   git commit -m "init blog"
   git branch -M main
   git remote add origin https://github.com/<你的用户名>/<你的用户名>.github.io.git
   git push -u origin main
   ```

4. 打开仓库 Actions 标签页，等部署完成
5. 访问 `https://<你的用户名>.github.io`

### 之后发新文章

```powershell
git add .
git commit -m "add: xxx writeup"
git push
```

推送后 GitHub Actions 会自动构建并发布。

## 常用配置

编辑 `quartz.config.yaml`：

- `pageTitle`：浏览器标签栏标题
- `locale`：界面语言（已设 zh-CN）
- `footer.links.GitHub`：换成你的 GitHub 链接
- `baseUrl`：部署后填你的 GitHub Pages 域名（可选，用于 SEO）
