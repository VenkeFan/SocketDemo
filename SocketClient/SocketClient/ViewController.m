//
//  ViewController.m
//  SocketClient
//
//  Created by fanqi_company on 2019/6/22.
//  Copyright © 2019 fanqi_company. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

NSString * const kHost = @"127.0.0.1";
uint16_t const kPort = 9999;

@interface ViewController () <GCDAsyncSocketDelegate> {
    dispatch_queue_t _socketQueue;
}

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (weak, nonatomic) IBOutlet UITextField *txtField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _socketQueue = dispatch_queue_create("com.fanqi.socketclient", DISPATCH_QUEUE_CONCURRENT);
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
}

- (IBAction)startConnect:(id)sender {
    [self connectToServer];
}

- (IBAction)closeConnection:(id)sender {
    [_socket disconnect];
}

- (IBAction)sendMessage:(id)sender {
    if (_txtField.text.length == 0) {
        return;
    }
    
    NSData *sendData = [_txtField.text dataUsingEncoding:NSUTF8StringEncoding];
    [_socket writeData:sendData withTimeout:-1 tag:0];
}

- (void)connectToServer {
    NSError *error = nil;
    
    [_socket connectToHost:kHost onPort:kPort error:&error];
    
    if (error) {
        NSLog(@"开始连接失败: %@", error);
    }
}


#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"%s", __func__);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (err) {
        NSLog(@"连接失败 %@", err);
    } else {
        NSLog(@"正常断开");
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"%s", __func__);
    
    [sock readDataWithTimeout:-1 tag:tag];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *receiverStr = [[NSString alloc] initWithData:data
                                                  encoding:NSUTF8StringEncoding];
    
    NSLog(@"%s %@", __func__, receiverStr);
}

@end
