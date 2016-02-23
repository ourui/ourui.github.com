---
layout: post
title: "Mantle 初步使用"
date: 2014-01-22 13:54:10 +0800
comments: true
categories: iOS
---

最近接触到了Mantle这个东西，感觉很不错，在此与各位分享一下。
<!-- more -->

###前言
在开发的过程中，我们常常会从网络获取数据，而数据通常又为JSON格式。 这时比较常见的做法是把JSON数据转为Model对象，这样我们可以从Model对象的属性读取数据。 但是常常会面临如下一些问题:

* 每次都要用 `-initWithDictionarty:(NSDictionary *)dict` 等类似的方法初始化，把JSON数据里的值一个一个的赋值给Modeld对象的属性，深深的感觉到自己在做重复的工作，有木有！

* 当你需要的某个数据在JSON字典数据里层次很深时，需要不断的使用 `[[obj objectForKey:@"key"] objectAtIndex:index] objectForKey:@""]...` 这样很长的代码，是不是感觉很不爽！

* 服务器给你返回的数据不是你期望的，例如：有些时候你需要的是一个NSString类型，但给你的是一个NSNumber。 有时你需要的是一个NSDate类型，但给你的是一个NSString类型，你还不得不去做一些判断，写一些转换的代码。 还有一种严重的情况，由于服务器故障，给你返回了一个NSNull，如果你没有做一些判断处理，那么这时你的程序崩溃的几率很大！

* 如何从这个Model对象，再还原成之前的JSON字典数据？ 其次，你想把这个Model对象存储下来的话，那么你不得不自己去处理NSCoding协议等一些烦人的问题，又是一些重复工作！

有没有办法可以很优雅的解决这些问题呢，这就是今天要说的Mantle框架。

###什么是Mantle？
Mantle是github的工程师们弄出来的东西，[github主页在此](https://github.com/MantleFramework/Mantle),
引用如下:
{% blockquote %}
Mantle makes it easy to write a simple model layer for your Cocoa or Cocoa Touch application.
{% endblockquote %}

###使用
下面就来说一下怎么使用，首先新建一个空的工程，把Mantle的代码下载下来，拖入你的工程。 我建议使用[CocoaPods](http://cocoapods.org)来管理第三方库，反正我就是这样干的，非常简单方便。 浏览一下框架的目录，大概如下图所示:

{%img /images/Mantle-01.png %}

居然这么多文件！ 不要害怕，我们常用到的就是`MTLJSONAdapter`和`MTLModle`而已。 `MTLModel`是一个抽象类，它帮我们做了很多工作，比如解决前言里提出的一些问题。 我们要建的Model类应该继承于它，此外你的继承类一定还要实现`MTLJSONSerializing`协议。 `MTLJSONAdapter`则是帮我们把JSON数据绑定到Model的属性里，当然，你不用担心会出现`NSNull`的情况，因为转换后它会自动设置成`nil`;

我们新建一个继承 `MTLModel` 的类，叫做 `TestDataModel`。 我们将从[这个地址](http://api.openweathermap.org/data/2.5/weather?lat=37.785834&lon=-122.406417&units=imperial)获取测试数据。 现在把想要的数据声明到头文件里

``` objc

//TestDataModel.h
#import <Mantle/Mantle.h>

@interface TestDataModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *humidity;
@property (nonatomic, strong) NSNumber *temperature;
@property (nonatomic, strong) NSNumber *tempHigh;
@property (nonatomic, strong) NSNumber *tempLow;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSDate *sunrise;
@property (nonatomic, strong) NSDate *sunset;
@property (nonatomic, strong) NSString *conditionDescription;
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSNumber *windBearing;
@property (nonatomic, strong) NSNumber *windSpeed;

@end


```

在`TestDataModel.m`文件里，实现`MTLJSONSerializing`协议里的`+ (NSDictionary *)JSONKeyPathsByPropertyKey` 方法。 


``` objc

//TestDataModel.m
#import "TestDataModel.h"

@implementation TestDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"date": @"dt", //将JSON字典里dt键对应的值，赋值给date属性
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",//这个点是什么意思呢，表示将main键对应的子字典里，
             							   //temp键对应的值赋给temperature属性。
             							   //我们不用再写 objectForKey]objectForKey]..这种代码了。
             							   //注意了：当main键对应的是数组时，main.temp返回的
             							   //为所有temp键对应值的数组合集

             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed",
            };
}

```

解释都在注释里。 Model类到此可以用了。 现在我们在`AppDelegate.m`里，编写相关的测试代码

``` objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURL *url = [NSURL URLWithString:@"http://api.openweathermap.org/data/2.5/weather?lat=37.785834&lon=-122.406417&units=imperial"];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
                               if (!connectionError) {
                                   NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                                        options:NSJSONReadingMutableContainers
                                                                                          error:nil];
                                   //将JSON数据和Model的属性进行绑定
                                   TestDataModel *model = [MTLJSONAdapter modelOfClass:[TestDataModel class]
                                                                    fromJSONDictionary:dict
                                                                                 error:nil];
                                   NSLog(@"%@",model);
                               }
                           }];

}

```
设置断点到15行，控制台显示如下图:

{%img /images/Mantle-02.png %}

可以看到所有属性值均已设置好了。 强大吧！ 等等...这好像和我们期望的类型不太一样，我们声明的date是一个NSDate型，但这里却是NSNumber。JSON数据里解析出来的就是NSNumber，那要怎么转化为我们期望的NSDate呢？ Mantle为我们提供了强大的转换机制。 继续回到`TestDataModel.m`文件里。添加如下代码:

``` objc
//TestDataModel.m

+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *dateNum) {
        return [NSDate dateWithTimeIntervalSince1970:dateNum.floatValue];
    } reverseBlock:^(NSDate *date) {
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
}
```
再次运行，控制台结果如下图:

{%img /images/Mantle-03.png %}

看见了吗，date已经成功转换为NSDate了！ 原来，上面的代码是要告知Mantle，赋值时要先进行转换，原始JSON里是一个NSNumber，现在转换为一个NSDate并返回。 其他属性需要转换的都可以这样做，方法命名规则是 `属性JSONTransformer`,那么在对这个属性进行赋值时就会调用这个方法先进行转换。当JSON数据里有NSNull的类型时，我们不用做任何处理，会自动将该属性置为nil；

那reverseBlock是干什么的呢？ 当要把Model转换回JSON数据时，如果设置了返回值，那么会将NSDate转回NSNumber返回JSON数据。 我们可以调用 `MTLJSONAdapter`的

``` objc
+ (NSDictionary *)JSONDictionaryFromModel:(MTLModel<MTLJSONSerializing> *)model;
``` 

方法将一个Model实例转回JSON数据。


####Model对象的存储:
由于MTLModel已经帮我们实现了NSCoding协议， 要把一个Model对象存储到本地就相当简单了，只需一行代码：

``` objc
[NSKeyedArchiver archiveRootObject:model toFile:path];

```

解档时同样简单：

``` objc
TestDataModel *unachiveModel = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
```

 Mantle还可以结合CoreData使用，这里不说了。 至此，Mantle的简单使用就介绍完了！ 如有什么不对之处，请各位谅解和指正！



###原理

没有深入研究源码，准备抽时间仔细研究一把。 大致看了下，Mantle主要使用了一些Runtime的东西，获取到所有propertiy属性进行绑定。 代码看起来有种不明觉厉的感觉，不得不感叹github上的牛人真多！ 想深入研究的同学可以多看下源码！


###参考文章

<https://github.com/MantleFramework/Mantle>































