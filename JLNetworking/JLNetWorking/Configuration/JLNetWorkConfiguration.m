//
//  JLNetWorkConfiguration.m
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "JLNetWorkConfiguration.h"

@implementation JLNetWorkConfiguration

- (instancetype)init{
    if (self = [super init]) {
        _cacheTimeSeconds = 0;
        _userCacheType = JLUseCacheTypeDefault;
#ifdef DEBUG
        _debugLogEnabled = YES;
#endif
        _networkTimeoutSeconds = 20.0f;
        _serviceArray = [NSMutableArray array];
        _defaultIsUsePublicParams = YES;
    }
    return self;
}

#pragma mark - public method
+ (JLNetWorkConfiguration *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)cleanAllRequestCacheData {
    
}

@end
