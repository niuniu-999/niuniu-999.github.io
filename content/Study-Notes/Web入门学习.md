---
publish: true
---

ctfshow题 + WP


**Web1**
找flag,右键检查源代码得到

 **ctfshow{fe753d30-6c68-44f7-83c4-f43d15c78ede}** 



**Web2**
 view-source: + URL可查看源代码

**ctfshow{a96edfca-76f2-45e8-a10a-8d0ac8c7dfa5}**



**Web3**
用Reqable抓包,flag在响应头里

**ctfshow{ff22f3d8-bb69-4249-b92f-c2286f74260b}**



**Web4**
robots.txt  爬虫协议   URL/robots.txt查看

**ctfshow{0c3ce399-b2c0-44e0-839e-69dbbe0718aa}**



**源码泄露**
同Web1

 **ctfshow{81c5ebb2-65b5-4a79-8f07-d0e8fee749b5}** 



**前台js绕过**
同Web2

**ctfshow{ae09e64d-73e4-4fc6-9d80-34e24f4b7870}**



**协议头泄露**
同Web3

**ctfshow{cf4f31a6-c2fe-40d2-9c7d-35035cb614d8}**



**前端密钥泄露**
检查源代码发现两行注释,一个id一个密码

u = 'admin' 
p = a599ac85a73384ee3219fa684296eaa62667238d608efa81837030bd1ce1bf04



