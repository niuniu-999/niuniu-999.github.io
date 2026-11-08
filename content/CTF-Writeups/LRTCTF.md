---
publish: true
---

1.**In Girl（Misc）**

`girl.zip` 解压后得到实际为 JPEG 的 `girl.png`。搜索文件特征可看到：

 JPEG 尾部藏有干扰串 `lrtctf{hint!flag}`；
 在偏移 `148552` 处还有完整 PNG 文件头和一张二维码。

按 PNG 文件头提取：

```bash
python3 - <<'PY'
b=open('girl.png','rb').read()
open('inner.png','wb').write(b[b.find(b'\x89PNG\r\n\x1a\n'):])
PY
```

扫描 `inner.png` 的二维码，得到：

lrtctf{139e1603741c4ffb4a88a7776d79ab6f}


## 2. Silent Broadcast（Crypto）

同一明文 `m` 分别用三组 RSA 参数加密，且 `e=3`，属于低指数广播攻击。  
对三组 `(n_i,c_i)` 做 CRT，恢复 `m^3 mod (n1*n2*n3)`；由于 `m^3` 小于模数乘积，直接开整数三次方根即可。


r = crt(c, n)
m = integer_nthroot(r, 3)[0]

lrtctf{h4st4d_br0adc4st_1s_n0t_s4fe}

## 3. 口算（Crypto）

附件给出 `p=61, q=53, e=17, n=3233`。计算：
phi=(p-1)(q-1)=3120
d=e^-1 mod phi=2753
m=c^d mod n=65

lrtctf{65}


## 4. go_back（Reverse）

题目中的四个变换都可逆。逆序执行：

1. 还原 `left`：先反转，再右旋；
2. 还原 `down`：再次逐位取反；
3. 还原 `right`：左旋相同位数；
4. 还原 `up`：每 8 位还原一个字符，并整除 2。

核心代码：
python
def dec(s, d=24):
    s = s[::-1]
    s = s[-d:] + s[:-d]
    s = ''.join('1' if c == '0' else '0' for c in s)
    s = s[d:] + s[:d]
    return ''.join(chr(int(s[i:i+8], 2) >> 1)
                   for i in range(0, len(s), 8))

lrtctf{XiaoSiGame}


## 5. HRDrev（Reverse）

程序被 UPX 加壳，先还原：
upx -d challenge2.exe -o unpacked.exe

`.text` 中存在自定义虚拟机。`bytecode.bin` 将 46 字节输入按每两个字符组成一个小端 16 位字，分别执行：
word -> xor A -> add B -> rol n -> xor C == 0
对每个 16 位字逐值求解，得到：
lrtctf{Th1s_ReV3r53_t4sk_1s_4_b1t_ch4ll3ng1ng}


## 6. 数学高手（Reverse）

程序把输入两两分组，校验每组字符的“和”与“差”：


a + b = sum_i
a - b = diff_i

a=(sum_i+diff_i)/2
b=(sum_i-diff_i)/2

lrtctf{welcome_lrtctf}


**7.LAP酱的旅行日记Ⅱ**

 Copyright = `fromliaoninghuludao`（辽宁葫芦岛出发）
 LensModel = `totianjing`（目的地天津）
 DateTimeOriginal = `2026:08:23 10:42:00`
 Make = `fake shooting time`、`FlashManufacturer` = `time_0911`（干扰项）
 lrtctf{辽宁葫芦岛_天津_2026/8/23_1042}



