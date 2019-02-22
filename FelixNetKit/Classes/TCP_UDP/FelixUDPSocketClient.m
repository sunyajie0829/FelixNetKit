//
//  FelixUDPSocketManager.m
//  FelixNetKit
//
//  Created by weistek on 2019/2/20.
//  Copyright © 2019 weistek. All rights reserved.
//

#import "FelixUDPSocketClient.h"
@interface FelixUDPSocketClient()<GCDAsyncUdpSocketDelegate>
@property (nonatomic,strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic,assign) int port;
@property (nonatomic,assign) BOOL enableBroadcast;
@end
@implementation FelixUDPSocketClient
- (instancetype)initWithPort:(int)port enableBroadcast:(BOOL)enableBroadcast delegate:(id<FelixUDPSocketDelegate>)delegate{
    if (self == [super init]){
        self.port = port;
        self.enableBroadcast = enableBroadcast;
        self.delegate = delegate;
        [self initSocket];
    }
    return self;
}
- (void)initSocket{
    if (!_udpSocket){
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        NSError *err = nil;
        [_udpSocket bindToPort:self.port error:&err];
        [_udpSocket enableBroadcast:YES error:&err];
        if (err){
            NSLog(@"start udp socket error:%@",err);
            [_udpSocket close];
            _udpSocket = nil;
            _udpSocket.delegate = nil;
            return;
        }else{
            [_udpSocket beginReceiving:&err];
        }
    }
    NSLog(@"udp socket start success");
}
- (void)sendBroadCast:(NSData *)data ToHost:(NSString *)host{
    if (_udpSocket){
        [_udpSocket sendData:data toHost:host port:self.port withTimeout:-1 tag:0];
    }else{
        NSLog(@"havn't start udp socket");
    }
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    if (!_udpSocket){
        return;
    }
    if ([self.delegate respondsToSelector:@selector(didReceiveData:fromIPAddress:)]){
        [self.delegate didReceiveData:data fromIPAddress:[GCDAsyncUdpSocket hostFromAddress:address]];
    }
}
- (void)closeUdpSocket{
    [_udpSocket close];
    _udpSocket = nil;
    _udpSocket.delegate = nil;
}
@end
