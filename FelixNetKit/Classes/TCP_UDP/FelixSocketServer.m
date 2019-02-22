//
//  FelixSocketServer.m
//  FelixNetKit
//
//  Created by weistek on 2019/2/20.
//  Copyright © 2019 weistek. All rights reserved.
//

#import "FelixSocketServer.h"
@interface FelixSocketServer()<GCDAsyncSocketDelegate>
@property (nonatomic,strong) GCDAsyncSocket *socket;
@property (nonatomic,strong) NSMutableDictionary<NSString *,NSMutableData *> *clientsDataPool;
@end
@implementation FelixSocketServer
+ (instancetype)sharedServer{
    static dispatch_once_t onceToken;
    static FelixSocketServer *server;
    dispatch_once(&onceToken, ^{
        server = [[FelixSocketServer alloc] init];
        [server initServer];
    });
    return server;
}
- (void)initServer{
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    _clients = [NSMutableDictionary dictionary];
    _clientsDataPool = [NSMutableDictionary dictionary];
}
- (void)startServerOnPort:(int)port welcomeData:(NSData * _Nullable)welcomeData{
    self.welcomeData = welcomeData ? welcomeData : [@"Hellow client" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    [_socket acceptOnPort:port error:&err];
    if (err){
        NSLog(@"start socket server error%@",err);
    }else{
        NSLog(@"start socket server success,listening port on:%d",port);
    }
}
- (void)disconnectWithClient:(GCDAsyncSocket *)client{
    if (client.connectedHost == nil){
        return;
    }
    [client disconnect];
}
- (void)sendData:(NSData *)data toSocketClient:(GCDAsyncSocket *)client{
    unsigned long length = data.length;
    NSMutableData *packageData = [NSMutableData dataWithBytes:&length length:sizeof(unsigned long)];
    [packageData appendData:data];
    if (client){
        [client writeData:packageData withTimeout:-1 tag:0];
    }else{
        NSLog(@"client dont exist");
    }
}
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    [_clients setValue:newSocket forKey:[NSString stringWithFormat:@"%lu",newSocket.hash]];
    [_clientsDataPool setValue:[NSMutableData data] forKey:[NSString stringWithFormat:@"%lu",newSocket.hash]];
    [self sendData:self.welcomeData toSocketClient:newSocket];
    [newSocket readDataWithTimeout:-1 tag:0];
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    [_clients removeObjectForKey:[NSString stringWithFormat:@"%lu",sock.hash]];
    [_clientsDataPool removeObjectForKey:[NSString stringWithFormat:@"%lu",sock.hash]];
    if ([self.delegate respondsToSelector:@selector(didDisconnectWithClient:)]){
        [self.delegate didDisconnectWithClient:sock];
    }
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSMutableData *clientDataPool = [_clientsDataPool valueForKey:[NSString stringWithFormat:@"%lu",sock.hash]];
    [clientDataPool appendData:data];
    [self processClientDataPool:clientDataPool client:sock];
    [sock readDataWithTimeout:-1 tag:0];
}
- (void)processClientDataPool:(NSMutableData *)clientDataPool client:(GCDAsyncSocket *)client{
    if (clientDataPool.length >= sizeof(unsigned long)){
        unsigned long length;
        [clientDataPool getBytes:&length range:NSMakeRange(0, sizeof(unsigned long))];
        if (length <= clientDataPool.length - sizeof(unsigned long)){
            if ([self.delegate respondsToSelector:@selector(didReceiveData:fromClient:)]){
                [self.delegate didReceiveData:[clientDataPool subdataWithRange:NSMakeRange(sizeof(unsigned long), length)] fromClient:client];
            }
            clientDataPool = [NSMutableData dataWithData:[clientDataPool subdataWithRange:NSMakeRange(sizeof(unsigned long) + length, clientDataPool.length - sizeof(unsigned long) - length)]];
            [self.clientsDataPool setValue:clientDataPool forKey:[NSString stringWithFormat:@"%lu",client.hash]];
            if (clientDataPool.length >= sizeof(unsigned long)){
                [self processClientDataPool:clientDataPool client:client];
            }
        }
    }
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if ([self.delegate respondsToSelector:@selector(sendDataSuccess)]){
        [self.delegate sendDataSuccess];
    }
}
@end
