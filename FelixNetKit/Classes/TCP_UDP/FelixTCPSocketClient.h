//
//  FelixTCPSocketManager.h
//  FelixNetKit
//
//  Created by weistek on 2019/2/20.
//  Copyright © 2019 weistek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
NS_ASSUME_NONNULL_BEGIN

@protocol FelixTCPSocktDelegate;

/**
 Socket的连接状态

 - FELIX_TCPSOCKET_CONNECTSTATE_CONNECTED: Socket处于连接状态，可以传输数据
 - FELIX_TCPSOCKET_CONNECTSTATE_ERROR: Socket连接错误，不可以传输数据
 - FELIX_TCPSOCKET_CONNECTSTATE_DISCONNECT: Socket未连接，不可以传输数据
 */
typedef NS_ENUM(int,FelixTCPSocketConnectState){
    FELIX_TCPSOCKET_CONNECTSTATE_CONNECTED = 1,
    FELIX_TCPSOCKET_CONNECTSTATE_ERROR,
    FELIX_TCPSOCKET_CONNECTSTATE_DISCONNECT,
};
@interface FelixTCPSocketClient : NSObject

/**
 Socket的代理
 */
@property (nonatomic,assign) id<FelixTCPSocktDelegate> delegate;

/**
 Socket的连接状态
 */
@property (nonatomic,assign) FelixTCPSocketConnectState connectState;

/**
 创建一个FelixTCPSocketClient对象实例

 @param host socket服务端的host
 @param port socket服务端的端口
 @param delegate 代理对象
 @return 返回FelixTCPSocketClient对象实例
 */
- (instancetype)initWithHost:(NSString *)host port:(int)port delegate:(id<FelixTCPSocktDelegate>)delegate;

/**
 发送数据(调用此方法后，为了解决粘包问题,会自动在数据前加上unsignd long类型的数据,内容为此次发送数据的长度),包装后的数据
 长度为sizeof(unsigned long)+data.length,服务端收到数据后，同样需要将前8个字节解析出来，决定后面读取多少个字节的数据。
 注:如果socket未连接，调用此方法后，会自动进行连接并发送当前的数据
 
 @param data 数据实体
 */
- (void)sendData:(NSData *)data;

/**
 建立socket连接到服务器
 */
- (void)connect;

/**
 断开与服务器的socket连接
 */
- (void)disconnect;
@end
@protocol FelixTCPSocktDelegate <NSObject>
@required

/**
 收到socket数据的回调,此处的data为处理后的数据(要求服务端发送数据时前8个字节存放真实数据的长度)

 @param data 数据内容
 @param client 对应的socket实体
 */
- (void)didReceiveData:(NSData *)data client:(FelixTCPSocketClient *)client;
@optional

/**
 监听连接状态的回调，也可利用KVO监听connectState

 @param connectState socket连接状态
 */
- (void)connectStateDidChange:(FelixTCPSocketConnectState)connectState;

/**
 客户端发送数据成功
 */
- (void)sendDataSuccess;
@end
NS_ASSUME_NONNULL_END
