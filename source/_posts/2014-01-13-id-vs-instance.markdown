---
layout: post
title: "id vs instancetype"
date: 2014-01-13 09:35:13 +0800
comments: true
categories: iOS
tags: language
---

不知道从什么时候开始IOS的SDK里多了一个叫_instancetype_的东西，顾名思义返回的就是一个实例对象，所以也没有深究。 但是这玩意和以前的id有什么区别呢，突然比较好奇。 上网查看了下相关的资料，自己也做了下测试，在这里记录一下。
<!-- more -->

  * 首先一个很重要的区别，id可以作为函数的参数和返回值，而instancetyp则只能作为返回值；

  * 其他区别，我用简单的话来概括就是: 

    如果返回的是instancetype，那么编译器是知道你返回的具体对象是什么类型，当你向这个实例发送不属于这个类的消息时，编译器则会报错。

  	{% img /images/instance_err_1.png %}

  	而id则是向它可以发送任何消息的，所以编译器不会报错,编译能通过

  	{% img /images/instance_normal.png %}

  	但是有一种特殊情况: 我们知道- (id)init 这个方法返回的是id，但是当你用这个方法生成的实例，向其发送不属于这个类的消息时，编译器也会报错。

  	{% img /images/instance_err_2.png %}

  	这是为什么呢，不是可以向id发送任意消息吗？ 原来这是因为编译器默认的初始化方法返回的是instancetype，你看着是id，但编译器实现时就是给你返回的是instancetype!  当我们用类方法返回的id，编译器才会真正的当成id处理。

###总结
  instancetype的出现，可以避免程序在运行时向某个对象发送不是它的消息引起崩溃，因为编译的时候就不让你通过。所以当你返回的对象确定为这个类的实例时，尽量使用instancetpye吧。 比如经常使用的单例模式，则可声明返回的为instancetype。
  仅仅是自己的理解，如有不对之处，请大家指正!

###参考文章
[_instancetype_](http://nshipster.com/instancetype/)