//
//  ViewController.m
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "ViewController.h"
#import "JLBaseService.h"
#import "JLNetwork.h"
#import "JLApi.h"
#import "AFNetworking.h"

@interface ViewController ()<JLRequestCallBackDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupZYNetworkingConfig];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(200, 100, 100, 100);
    [button setBackgroundColor:[UIColor redColor]];
    [button addTarget:self action:@selector(a) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)requestCallAPIDidCompletion:(JLRequest *)request {
    NSLog(@"完成回调%@",request);
}

- (void)a {
    JLApi *api = [[JLApi alloc] init];
    [api startWithCompletionBlock:^(JLRequest *request) {
        NSLog(@"完成回调%@",request);
    }];
    
    api.delegate = self;
    [api start];
}

- (void)setupZYNetworkingConfig {
    if ([JLNetWorkConfiguration sharedInstance].serviceArray.count <= 0) {
        [[JLNetWorkConfiguration sharedInstance].serviceArray addObject:NSStringFromClass([JLBaseService class])];
        [JLNetWorkConfiguration sharedInstance].userCacheType = JLUseCacheTypeDefault;
        [JLNetWorkConfiguration sharedInstance].networkTimeoutSeconds = 60;
    }
}


@end
