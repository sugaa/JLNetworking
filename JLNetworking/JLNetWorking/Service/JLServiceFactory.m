//
//  JLServiceFactory.m
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "JLServiceFactory.h"
#import "JLNetWorkConfiguration.h"
#import "JLLoger.h"

@implementation JLServiceFactory

#pragma mark - life cycle
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static JLServiceFactory *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JLServiceFactory alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public methods
- (JLService<JLServiceProtocol> *)serviceWithIdentifier:(NSString *)identifier {
    
    BOOL isFindService = NO;
    for (NSString *serviceClassName in [JLNetWorkConfiguration sharedInstance].serviceArray) {
        if ([serviceClassName isEqualToString:identifier]) {
            isFindService = YES;
            break;
        }
    }
    
    if (!isFindService) {
        NSException *exception = [[NSException alloc] initWithName:[NSString stringWithFormat:@"没有找到<%@> service",identifier] reason:[NSString stringWithFormat:@"请检查[JLNetworkingConfiguration sharedInstance].serviceArray 是否添加了<%@> service",identifier] userInfo:nil];
        @throw exception;
    }
    
    return [[NSClassFromString(identifier) alloc] init];
}

@end
