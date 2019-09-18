//
//  JLService.m
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "JLService.h"
#import "JLNetWorkConfiguration.h"

@implementation JLService

#pragma mark - life cycle
- (instancetype)init {
    if (self = [super init]) {
        _validator = nil;
        if ([self conformsToProtocol:@protocol(JLServiceProtocol)]) {
            self.protocol = (id<JLServiceProtocol>)self;
        } else {
            NSException *exception = [[NSException alloc] initWithName:@"子类必须遵循<JLServiceProtocol>" reason:[NSString stringWithFormat:@"%@必须遵循<JLServiceProtocol>",NSStringFromClass([self class])] userInfo:nil];
            @throw exception;
        }
    }
    return self;
}

#pragma mark - getters and setters
- (NSString *)baseUrl {
    return self.protocol.apiBaseUrl;
}

- (NSString *)version {
    return self.protocol.apiVersion;
}

- (NSDictionary *)publicParams {
    return self.protocol.apiPublicParams;
}

#pragma mark - 默认值

- (NSString *)apiBaseUrl {
    return nil;
}

- (NSDictionary *)apiPublicParams {
    return nil;
}

- (NSString *)apiVersion {
    return nil;
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    return nil;
}

@end
