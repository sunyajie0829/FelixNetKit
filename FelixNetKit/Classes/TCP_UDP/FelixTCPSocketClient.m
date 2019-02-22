//
//  FelixTCPSocketManager.m
//  FelixNetKit
//
//  Created by weistek on 2019/2/20.
//  Copyright © 2019 weistek. All rights reserved.
//

#import "FelixTCPSocketClient.h"
@interface FelixTCPSocketClient()<GCDAsyncSocketDelegate>
@property (nonatomic,strong) GCDAsyncSocket *socket;
@property (nonatomic,strong) NSMutableData *dataPool;
@property (nonatomic,strong) NSData *cachedData;
@property (nonatomic,strong) NSString *host;
@property (nonatomic,assign) int port;
@end
@implementation FelixTCPSocketClient
- (instancetype)initWithHost:(NSString *)host port:(int)port delegate:(id<FelixTCPSocktDelegate>)delegate{
    if (self == [super init]){
        self.host = host;
        self.port = port;
        self.delegate = delegate;
        [self initSocket];
    }
    return self;
}
- (void)initSocket{
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    self.dataPool = [NSMutableData data];
    self.connectState = FELIX_TCPSOCKET_CONNECTSTATE_DISCONNECT;
}
- (void)connect{
    if (self.connectState == FELIX_TCPSOCKET_CONNECTSTATE_CONNECTED){
        return;
    }
    NSError *err = nil;
    [_socket connectToHost:self.host onPort:self.port error:&err];
    if (!err){
        NSLog(@"Socket初始化成功");
    }else{
        NSLog(@"Socket初始化失败");
    }
}
- (void)disconnect{
    if (self.connectState == FELIX_TCPSOCKET_CONNECTSTATE_DISCONNECT){
        return;
    }
    [self.socket disconnect];
}
- (void)sendData:(NSData *)data{
    //为data添加4个字节的头，值为data的长度
    unsigned long length = data.length;
    NSMutableData *packageData = [NSMutableData dataWithBytes:&length length:sizeof(unsigned long)];
    [packageData appendData:data];
    if (self.connectState == FELIX_TCPSOCKET_CONNECTSTATE_CONNECTED){
        [_socket writeData:packageData withTimeout:-1 tag:0];
    }else{
        self.cachedData = data;
        [self connect];
    }
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    if ([self.delegate respondsToSelector:@selector(sendDataSuccess)]){
        [self.delegate sendDataSuccess];
    }
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [_dataPool appendData:data];
    [self processDataPool:_dataPool client:self];
    [self.socket readDataWithTimeout:-1 tag:0];
}
- (void)processDataPool:(NSMutableData *)data client:(FelixTCPSocketClient *)client{
    if (data.length >= sizeof(unsigned long)){
        unsigned long length;
        [data getBytes:&length range:NSMakeRange(0, sizeof(unsigned long))];
        if (length <= data.length - sizeof(unsigned long)){
            if ([self.delegate respondsToSelector:@selector(didReceiveData:client:)]){
                [self.delegate didReceiveData:[data subdataWithRange:NSMakeRange(sizeof(unsigned long), length)] client:self];
            }
            data = [NSMutableData dataWithData:[data subdataWithRange:NSMakeRange(sizeof(unsigned long) + length, data.length - sizeof(unsigned long) - length)]];
            _dataPool = data;
            if (data.length >= sizeof(unsigned long)){
                [self processDataPool:data client:self];
            }
        }
    }
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    self.connectState = FELIX_TCPSOCKET_CONNECTSTATE_CONNECTED;
    if ([self.delegate respondsToSelector:@selector(connectStateDidChange:)]){
        [self.delegate connectStateDidChange:self.connectState];
    }
    if (self.cachedData){
        [self sendData:self.cachedData];
        self.cachedData = nil;
    }
    [self.socket readDataWithTimeout:-1 tag:0];
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (err){
        self.connectState = FELIX_TCPSOCKET_CONNECTSTATE_ERROR;
    }else{
        self.connectState = FELIX_TCPSOCKET_CONNECTSTATE_DISCONNECT;
    }
    if ([self.delegate respondsToSelector:@selector(connectStateDidChange:)]){
        [self.delegate connectStateDidChange:self.connectState];
    }
    self.cachedData = nil;
}
@end
