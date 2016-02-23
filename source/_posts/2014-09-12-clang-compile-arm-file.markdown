---
layout: post
title: "Mac上用 clang 简单交叉编译arm架构的文件"
date: 2014-09-12 09:58:38 +0800
comments: true
categories: iOS
---

在Mac上简单的编译出一个可以在 IOS 上运行的 hello world 程序:

<!-- more -->

* 写一个简单的hello world程序，保存到桌面或者其他地方

* 终端里cd 到刚才保存的路径

* 运行命令:
	
``` objc

// -arch 表示要编译的架构 这里为armv7.
// -isysroot 指定头文件的根路径
$	clang -arch armv7 -o hello hello.c -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.1.sdk

//也可以使用xcrun
$   xcrun -sdk iphoneos clang -arch armv7 -o hello hello.c //xcrun -sdk 会使用最新的sdk去编译

```

* 使用file命令查看编译出来的文件是什么架构	
	

``` objc

$	file hello //output: 'hello: Mach-O executable arm'

```

* scp 到越狱ios设备运行

``` objc

$	./hello

```

成功输出 hello world






