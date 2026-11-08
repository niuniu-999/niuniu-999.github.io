---
title: 🏡 CTF Garden
publish: true
---

欢迎来到我的数字花园！这里记录我的 **CTF 解题 Writeup** 和 **学习笔记**。

## 📂 目录导航

- [[CTF-Writeups/|🎯 CTF Writeups]] — 比赛解题报告
- [[Study-Notes/|📚 学习笔记]] — Web安全 / 逆向 / 密码学等学习记录

## 🚀 近期更新

```dataview
TABLE title AS "标题", file.mtime AS "更新时间"
FROM "CTF-Writeups" OR "Study-Notes"
SORT file.mtime DESC
LIMIT 5
```

## 🛠️ 技术栈

- 写作：Obsidian
- 站点：Quartz 5
- 部署：GitHub Pages
