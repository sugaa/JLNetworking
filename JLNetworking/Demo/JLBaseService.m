//
//  JLBaseService.m
//  JLNetworking
//
//  Created by qmg on 2018/8/28.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "JLBaseService.h"

@implementation JLBaseService

#pragma mark - ---------- cycle life
- (instancetype)init {
    if (self = [super init]) {
        self.validator = self;
    }
    return self;
}

/*2.放置自定义代理和数据源方法*/
#pragma mark - ---------- custom delegate && datasource
#pragma mark -JLServiceProtocal

- (NSString *)apiBaseUrl {
    return @"https://apim.qmango.com/boutiqueapi/hotel.asmx";
}


- (NSDictionary *)requestHeaderFieldValueDictionary {
    
    NSMutableDictionary *requestHeaders = [NSMutableDictionary dictionary];
    
    return requestHeaders;
}

#pragma mark - JLServiceValidator
- (BOOL)service:(JLService *)service verifyWithParamsData:(NSDictionary *)data {
    return YES;
}

- (BOOL)service:(JLService *)service verifyWithCallBackData:(NSDictionary *)data {
    NSString *code = data[@"RespCode"];
    if (![code isEqualToString:@"0"]) {
        NSString *tipString = data[@"msg"];
        if (tipString) {
            NSLog(@"%@",tipString);
        }
    }
    if ([code isEqualToString:@"0"]) {
        return YES;
    }
    return NO;
}

@end
