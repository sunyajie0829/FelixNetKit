//
//  FelixSocketServer.h
//  FelixNetKit
//
//  Created by weistek on 2019/2/20.
//  Copyright © 2019 weistek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
NS_ASSUME_NONNULL_BEGIN

@protocol FelixSocketServerDelegate;
@interface FelixSocketServer : NSObject

/**
 已经建立连接的socket客户端
 */
@property (nonatomic,strong,readonly) NSMutableDictionary *clients;

/**
 连接成功后默认返回给客户端的内容
 */
@property (nonatomic,strong) NSData *welcomeData;

/**
 处理回调的代理对象
 */
@property (nonatomic,assign) id<FelixSocketServerDelegate> delegate;

/**
 此处采用单例来管理服务端

 @return 返回FelixSocketServer单例对象
 */
+ (instancetype)sharedServer;

/**
 开启socket服务器

 @param port socket服务器的端口
 @param welcomeData 连接成功后默认返回给客户端的内容
 */
- (void)startServerOnPort:(int)port welcomeData:(NSData * _Nullable)welcomeData;
/**
 关闭socket服务器
 */
- (void)stopServer;
/**
 发送数据给客户端

 @param data 发送数据的内容(内部会在当前的数据头部增加8个unsignd long类型的数据，内容为data的长度)
 @param client socket客户端
 */
- (void)sendData:(NSData *)data toSocketClient:(GCDAsyncSocket *)client;

/**
 主动断开与某个客户端的连接

 @param client socket客户端
 */
- (void)disconnectWithClient:(GCDAsyncSocket *)client;
@end
@protocol FelixSocketServerDelegate <NSObject>
@required

/**
 收到来自于某个客户端的数据

 @param data 接收到来自客户端的数据(已经自动去除了客户端前8个字节的数据长度信息)
 @param client socket客户端
 */
- (void)didReceiveData:(NSData *)data fromClient:(GCDAsyncSocket *)client;
@optional

/**
 与客户端的连接断开的回调,内部自动更新clients

 @param client 断开的socket客户端
 */
- (void)didDisconnectWithClient:(GCDAsyncSocket *)client;

/**
 发送数据成功的回调
 */
- (void)sendDataSuccess;
@end
NS_ASSUME_NONNULL_END
