---
layout: post
title: "NSInputStream 和 NSOutputStream"
date: 2014-09-11 21:03:56 +0800
comments: true
categories: iOS
---

对于 NSInputStream 和 NSOutputStream 一直没怎么搞清楚，今天抽一些时间在此记录一下！

NSInputStream 与 NSOutputStream 都继承于 NSStream, NSStream 是一个抽象的基类, 规定了Stream共有的一些行为...

<!-- more -->

###什么是Stream

Stream翻译成为流，它是对我们读写文件的一个抽象。 你可以这样想象，当你读文件和写文件的时候，文件的内容就像水流一样哗哗的
像你流过来或者流给别人，这样岂不是很爽。 而Stream就帮我们做了这样的事情， 实际上，它是把文件的内容，一小段一小段的读出或
写入，来到达这样的效果

###NSStream

NSStream 是Cocoa平台下对流这个概念的实现类， NSInputStream 和 NSOutputStream 则是它的两个子类，分别对应了读文件和
写文件。


###NSInputStream

NSInputStream 对应的是读文件，所以要记住它是要将文件的内容读到内存(你声明的一段buffer)里, 下面一段是测试代码


``` objc

- (void)doTestInputStream {
	NSString *path = @"/Users/usr/Desktop/stream.txt";
	
	NSInputStream *readStream = [[NSInputStream alloc]initWithFileAtPath:path];
	[readStream setDelegate:self];
	
	[readStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[readStream open]; //调用open开始读文件
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	switch (eventCode) {
		case NSStreamEventHasBytesAvailable:{
			
			uint8_t buf[1024];
			
			NSInputStream *reads = (NSInputStream *)aStream;
			NSInteger blength = [reads read:buf maxLength:sizeof(buf)]; //把流的数据放入buffer
			NSData *data = [NSData dataWithBytes:(void *)buf length:blength];
			
			NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
			NSLog(@"%@",string);
		}
			break;
					

		//错误和无事件处理
		case NSStreamEventErrorOccurred:{
			
		}
			break;
		case NSStreamEventNone:
			break;
		
		//打开完成
		case NSStreamEventOpenCompleted: {
			NSLog(@"NSStreamEventOpenCompleted");
		}
			break;
			
		default:
			break;
	}
}

@end

```

###NSOutputStream

NSOutputStream 对应的是写文件，它是要将已存在的内存(buffer)里的数据写入文件, 下面同样一段是测试代码

``` objc

- (NSData *)dataWillWrite {
	static  NSData *data = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		data = [NSData dataWithContentsOfFile:@"/Users/usr/Desktop/stream.txt"];
	});
	
	return data;
}

- (void)doTestOutputStream {
	NSString *path = @"/Users/usr/Desktop/stream-write.txt";
	
	NSOutputStream *writeStream = [[NSOutputStream alloc] initToFileAtPath:path append:YES];
	[writeStream setDelegate:self];
	
	[writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[writeStream open];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	switch (eventCode) {
		case NSStreamEventHasSpaceAvailable: {
			
			NSInteger bufSize = 5;
			uint8_t buf[bufSize];
			
			if (self.location + bufSize > [self dataWillWrite].length) {
				[[self dataWillWrite] getBytes:buf
										 range:NSMakeRange(self.location, self.location + bufSize - [self dataWillWrite].length)];
			}
			else {
				[[self dataWillWrite] getBytes:buf range:NSMakeRange(self.location, bufSize)];
			}
			
			NSOutputStream *writeStream = (NSOutputStream *)aStream;
			[writeStream write:buf maxLength:sizeof(buf)]; //把buffer里的数据，写入文件
			
			self.location += bufSize;
			if (self.location >= [[self dataWillWrite] length] ) { //写完后关闭流
				[aStream close];
			}
			
		}
			break;
			
		case NSStreamEventEndEncountered: {
			[aStream close];
		}
			break;
		
		//错误和无事件处理
		case NSStreamEventErrorOccurred:{
			
		}
			break;
		case NSStreamEventNone:
			break;
		
		//打开完成
		case NSStreamEventOpenCompleted: {
			NSLog(@"NSStreamEventOpenCompleted");
			
			
		}
			break;
			
		default:
			break;
	}
}
```

### 用途

NSInputStream 和 NSOutputStream 常用与网络传输中，比如要将一个很大的文件传送给服务器，那么NSInputStream这时候是
很好的选择, 我们可以查看到 NSURLRequest 有一个属性叫HTTPBodyStream， 这时只要设置好一个NSInputStream的实例就可以
了，最大的好处就是可以节省我们很多的内存。

另外要说明的是，NSInputStream 和 NSOutputStream其实是对 CoreFoundation 层对应的CFReadStreamRef 和 CFWriteStreamRef
的高层抽象。在使用CFNetwork时，常常会使用到CFReadStreamRef 与 CFWriteStreamRef。 下面是一段相关代码

``` objc

	// Keep a reference to self to use for controller callbacks
    //
	CFStreamClientContext ctx = {0, (__bridge void *)(self), NULL, NULL, NULL};
	
	// Get callbacks for stream data, stream end, and any errors
    //
	CFOptionFlags registeredEvents = (kCFStreamEventHasBytesAvailable | kCFStreamEventEndEncountered | kCFStreamEventErrorOccurred);
	
	// Create a read-only socket
    //
	CFReadStreamRef readStream;
	CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)host, (UInt32)port, &readStream, NULL);
	
	// Schedule the stream on the run loop to enable callbacks
    //
	if (CFReadStreamSetClient(readStream, registeredEvents, socketCallback, &ctx)) {
		CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
		
	}
    else {
        [self networkFailedWithErrorMessage:@"Failed to assign callback method"];
		return;
	}
	
	// Open the stream for reading
    //
	if (CFReadStreamOpen(readStream) == NO) {
        [self networkFailedWithErrorMessage:@"Failed to open read stream"];
		
		return;
	}
	
	CFErrorRef error = CFReadStreamCopyError(readStream);
	if (error != NULL) {
		if (CFErrorGetCode(error) != 0) {
			NSString * errorInfo = [NSString stringWithFormat:@"Failed to connect stream; error '%@' (code %ld)", (__bridge NSString*)CFErrorGetDomain(error), CFErrorGetCode(error)];
            [self networkFailedWithErrorMessage:errorInfo];
		}
		
		CFRelease(error);
		
		return;
	}
```







