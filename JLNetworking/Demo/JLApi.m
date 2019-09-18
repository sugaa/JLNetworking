//
//  JLApi.m
//  JLNetworking
//
//  Created by qmg on 2018/8/28.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "JLApi.h"
#import "JLBaseService.h"

@implementation JLApi

#pragma mark - JLRequestProtocol
- (JLRequestType)requestType {
    return JLRequestTypeGet;
}

- (NSString *)serviceType {
    return NSStringFromClass([JLBaseService class]);
}

- (NSString *)requestUrl {
    return @"getAdvInfoV2";
}

- (NSDictionary *)requestParams {
    return @{@"picSize":@""};
}

@end
