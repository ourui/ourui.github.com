---
layout: post
title: "Toll Free Bridging 的秘密"
date: 2015-03-08 19:07:46 +0800
comments: true
categories: iOS
tags: briding
---

Toll free briding 是用于 Foundation对象和Core Foundation对象间无缝转换的一种方法。首先，我们来看看下面代码:
<!-- more  -->
``` objc 

 CFStringRef cfStr = SomeFunctionThatReturnsCFString();
 NSUInteger length = [(NSString *)cfStr length];
    
 NSString *nsStr = [self someString];
 CFIndex length = CFStringGetLength((CFStringRef)nsStr);

```

我们可以将一个 `CFStringRef` 类型的变量通过指针转换为 `NSString *` 类型, 然后直接当作NSString 使用, 向其发送消息。
同时，我们也可以将 `NSString *`通过指针转换为 `CFStringRef`,  即可当作CFStringRef，对于 CFStringRef 申明的C层级的
API 均能使用。这便是官方所说得 Toll free briding。

那么这一切是如何做到的，内部发生了什么？ 

###CF 转为 OBJC
首先，我们来看看CF对象是怎样转为OBJC对象的。 这个方向的转换比较简单。 在OBJC的类里，绝大多数能进行bridging的类都是一层抽象封装，叫做类族。如`NSString`, 我们在得到真正的实例时是它的一个私有子类`NSCFString`。 而`CFStringRef` 和 `NSCFString` 对象具有相同的内存布局， `CFStringRef` 的前4个字节也是一个 `isa` 指针
，指向 `NSCFString` 类。 由OBJC的消息发送机制我们可以知道，这时候，对其发送OBJC的消息，和对OBJC的对应对象发送消息是一模一样的！

###OBJC 转为 CF
还以`NSString`为列。上面我们说了：`CFStringRef` 和 `NSCFString` 对象具有相同的内存布局。 这时候，你可能要说了，既然是
相同的内存布局，直接作指针转换就好了！ OBJC对象即可当作CF对象！ 可是，有一些情况比较例外。如果我们写了一个类，继承于
`NSString`, 重写了 `length` 方法。 那么这时候，这个对象则和 `CFStringRef` 不再具有相同的内存布局，它们的`isa`指针指向不同的
类了。 但是这种情况我们任然是可以作bridging的。这又是怎么办到的？ 

CF在他的API里，都做了一个OBJC方法名的映射，如 `CFStringGetLength`: 

``` objc

 CFIndex CFStringGetLength(CFStringRef str) {

        CF_OBJC_FUNCDISPATCH0(__kCFStringTypeID, CFIndex, str, "length");
    
        __CFAssertIsString(str);
        return __CFStrLength(str);
}

```

`CFStringGetLength` 映射了 `NSString` 的 	`length`方法！

`CF_OBJC_FUNCDISPATCH0` 就是要去判断传进来的str究竟是不是`NSCFString`,如果是则调用 `__CFStrLength` 函数返回。 
如果不是，则向这个对象发送 `length` 消息，并返回。 如果我们传入的是自己继承NSString的对象，
那么这时候则会向这个对象发送`length`消息，重写的方法就得到了调用！


注：ARC下的bridging，需要用到`__bridge`, `__bridge_retained`, `__bridge_transfer`修饰符，本文不作讨论。


###参考
[Friday Q&A 2010-01-22: Toll Free Bridging Internals](https://www.mikeash.com/pyblog/friday-qa-2010-01-22-toll-free-bridging-internals.html)



