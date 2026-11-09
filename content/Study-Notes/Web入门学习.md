---
title: ctfshow Web 入门通关笔记
publish: true
tags: [web, ctfshow, 学习笔记]
description: ctfshow Web 入门题通关记录：查看源码、view-source、抓包看响应头、robots.txt、源码泄露、前端 JS 绕过、协议头泄露、前端密钥泄露
---

## Web1 — 查看源码

找 flag，右键检查源代码得到。

```text
ctfshow{fe753d30-6c68-44f7-83c4-f43d15c78ede}
```

## Web2 — view-source

`view-source:` + URL 直接查看页面源码。

```text
ctfshow{a96edfca-76f2-45e8-a10a-8d0ac8c7dfa5}
```

## Web3 — 响应头

用 Reqable 抓包，flag 在响应头里。

```text
ctfshow{ff22f3d8-bb69-4249-b92f-c2286f74260b}
```

## Web4 — robots.txt

爬虫协议，访问 `URL/robots.txt` 查看。

```text
ctfshow{0c3ce399-b2c0-44e0-839e-69dbbe0718aa}
```

## 源码泄露

思路同 Web1（备份文件 / 源码泄露）。

```text
ctfshow{81c5ebb2-65b5-4a79-8f07-d0e8fee749b5}
```

## 前台 JS 绕过

思路同 Web2，直接看前端 JS。

```text
ctfshow{ae09e64d-73e4-4fc6-9d80-34e24f4b7870}
```

## 协议头泄露

思路同 Web3，抓包看请求/响应头。

```text
ctfshow{cf4f31a6-c2fe-40d2-9c7d-35035cb614d8}
```

## 前端密钥泄露

检查源代码发现两行注释，一个 id 一个密码：

```text
u = 'admin'
p = a599ac85a73384ee3219fa684296eaa62667238d608efa81837030bd1ce1bf04
```
