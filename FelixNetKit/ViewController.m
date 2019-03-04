//
//  ViewController.m
//  FelixNetKit
//
//  Created by weistek on 2019/2/19.
//  Copyright © 2019 weistek. All rights reserved.
//

#import "ViewController.h"
#import "Classes/FelixNetKit.h"
@interface ViewController ()<FelixTCPSocktDelegate>
@property (nonatomic,strong) FelixTCPSocketClient *socket;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)connectAction:(id)sender {
    _socket = [[FelixTCPSocketClient alloc] initWithHost:@"192.168.10.114" port:9988 delegate:self];
    [_socket connect];
}
- (IBAction)sendData:(id)sender {
    [_socket sendData:[@"ddd" dataUsingEncoding:NSUTF8StringEncoding]];
}
- (IBAction)disconnectAction:(id)sender {
    [_socket disconnect];
    _socket = nil;
}
- (void)connectStateDidChange:(FelixTCPSocketConnectState)connectState{
    NSLog(@"%d",connectState);
}
- (void)didReceiveData:(NSData *)data client:(FelixTCPSocketClient *)client{
    NSLog(@"client receive data:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}
@end
