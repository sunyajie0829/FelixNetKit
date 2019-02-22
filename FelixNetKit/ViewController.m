//
//  ViewController.m
//  FelixNetKit
//
//  Created by weistek on 2019/2/19.
//  Copyright © 2019 weistek. All rights reserved.
//

#import "ViewController.h"
#import "Classes/FelixNetKit.h"
@interface ViewController ()<FelixTCPSocktDelegate,FelixSocketServerDelegate>
@property (nonatomic,strong) FelixTCPSocketClient *socket0;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[FelixHttpManager sharedManager] GETWithUrlStr:@"" parameter:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    _socket0 = [[FelixTCPSocketClient alloc] initWithHost:@"192.168.10.107" port:9988 delegate:self];

//
//    FelixTCPSocket *socket1 = [[FelixTCPSocket alloc] init];
//    socket1.host = @"192.168.10.107";
//    socket1.port = 9988;
//    socket1.delegate = self;
//
//    FelixTCPSocket *socket2 = [[FelixTCPSocket alloc] init];
//    socket2.host = @"192.168.10.107";
//    socket2.port = 9988;
//    socket2.delegate = self;
    
    
    [FelixSocketServer sharedServer].delegate = self;
    [[FelixSocketServer sharedServer] startServerOnPort:9988 welcomeData:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_socket0 sendData:[@"socket0" dataUsingEncoding:NSUTF8StringEncoding]];
//        [socket1 sendData:[@"socket1" dataUsingEncoding:NSUTF8StringEncoding]];
//        [socket2 sendData:[@"socket2" dataUsingEncoding:NSUTF8StringEncoding]];
    });
    
//    [FelixTCPSocket sharedSocket].host = @"192.168.10.107";
//    [FelixTCPSocket sharedSocket].port = 9988;
//    [FelixTCPSocket sharedSocket].delegate = self;
//    [[FelixTCPSocket sharedSocket] connect];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[FelixTCPSocket sharedSocket] sendData:[@"i am felilx 1" dataUsingEncoding:NSUTF8StringEncoding]];
//        [[FelixTCPSocket sharedSocket] sendData:[@"i am fesdflilx 2" dataUsingEncoding:NSUTF8StringEncoding]];
//        [[FelixTCPSocket sharedSocket] sendData:[@"i am felsadfilx 3" dataUsingEncoding:NSUTF8StringEncoding]];
//        [[FelixTCPSocket sharedSocket] sendData:[@"i am feasfasdfasdflilx 4" dataUsingEncoding:NSUTF8StringEncoding]];
//        [[FelixTCPSocket sharedSocket] sendData:[@"i am felisadflx 5" dataUsingEncoding:NSUTF8StringEncoding]];
//        [[FelixTCPSocket sharedSocket] sendData:[@"i am felidflx 6" dataUsingEncoding:NSUTF8StringEncoding]];
//        [[FelixTCPSocket sharedSocket] sendData:[@"i am felsfasdfasfasdfilx 7" dataUsingEncoding:NSUTF8StringEncoding]];
//        [[FelixTCPSocket sharedSocket] sendData:[@"i am feliflx 8" dataUsingEncoding:NSUTF8StringEncoding]];
//        [[FelixTCPSocket sharedSocket] sendData:[@"i am felifaflx 9" dataUsingEncoding:NSUTF8StringEncoding]];
//        [[FelixTCPSocket sharedSocket] sendData:[@"i am felisalx 10" dataUsingEncoding:NSUTF8StringEncoding]];
//        [[FelixTCPSocket sharedSocket] sendData:[@"i am feliadfasdflx 11" dataUsingEncoding:NSUTF8StringEncoding]];
//        [[FelixTCPSocket sharedSocket] sendData:[@"i am feliasdfsdlx 12" dataUsingEncoding:NSUTF8StringEncoding]];
    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[FelixTCPSocket sharedSocket] sendData:[@"i am felilx 3" dataUsingEncoding:NSUTF8StringEncoding]];
//    });
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[FelixTCPSocket sharedSocket] sendData:[@"i am felilx 5" dataUsingEncoding:NSUTF8StringEncoding]];
//    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[FelixTCPSocket sharedSocket] sendData:[@"i am felilx 10" dataUsingEncoding:NSUTF8StringEncoding]];
//        [[FelixTCPSocket sharedSocket] disconnect];
    });
}
- (void)didReceiveData:(NSData *)data fromClient:(GCDAsyncSocket *)client{
    NSLog(@"server receive data:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [[FelixSocketServer sharedServer] sendData:[@"got it" dataUsingEncoding:NSUTF8StringEncoding] toSocketClient:client];
}
- (void)didReceiveData:(nonnull NSData *)data client:(nonnull FelixTCPSocketClient *)client {
    NSLog(@"client receive data:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}
@end
