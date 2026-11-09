---
title: 关于本站
publish: true
description: 这个站点是什么、写了什么、怎么更新
---

## 这是哪里

一个用 [Obsidian](https://obsidian.md) 写、用 [Quartz 5](https://quartz.jzhao.xyz) 生成的数字花园，专门放我的 CTF 解题记录与 Web 安全学习笔记。

主要内容：

- **CTF Writeups**：Misc、Crypto、Web、Reverse 方向的比赛题目解法与脚本
- **Study Notes**：ctfshow、靶场、工具链的学习记录

## 怎么更新

笔记直接写在 Obsidian 库里，开头加 `publish: true` 就会出现在站上；不加则只留在本地。推送到 GitHub 后由 Actions 自动构建发布。

```yaml
---
title: 一篇新的 Writeup
publish: true
tags: [web, misc]
---
```

## 联系方式

- GitHub：[niuniu-999](https://github.com/niuniu-999)
