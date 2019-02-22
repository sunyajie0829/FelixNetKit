//
//  FelixUDPSocketManager.h
//  FelixNetKit
//
//  Created by weistek on 2019/2/20.
//  Copyright © 2019 weistek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
NS_ASSUME_NONNULL_BEGIN
@protocol FelixUDPSocketDelegate;
@interface FelixUDPSocketClient : NSObject
@property (nonatomic,assign) id<FelixUDPSocketDelegate> delegate;

/**
 创建一个FelixUDPSocketClient实体

 @param port UDP服务端的端口
 @param enableBroadcast 是否开启广播，网络发现必须允许开启
 @param delegate 处理回调的代理
 @return 返回FelixUDPSocketClient实体
 */
- (instancetype)initWithPort:(int)port enableBroadcast:(BOOL)enableBroadcast delegate:(id<FelixUDPSocketDelegate>)delegate;

/**
 发送广播

 @param data 发送数据的内容(未进行任何包装)
 @param host 发送广播的地址,当前局域网建议为"255.255.255.255"
 */
- (void)sendBroadCast:(NSData *)data ToHost:(NSString *)host;

/**
 关闭socket，建议用完一定关闭
 */
- (void)closeUdpSocket;
@end
@protocol FelixUDPSocketDelegate <NSObject>
@required

/**
 收到数据的回调

 @param data 收到的数据内容
 @param ipAddress 发送数据的ipz地址即设备地址
 */
- (void)didReceiveData:(NSData *)data fromIPAddress:(NSString *)ipAddress;
@end
NS_ASSUME_NONNULL_END
