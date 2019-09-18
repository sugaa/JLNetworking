//
//  JLRequestProxy.h
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JLRequest;
@class JLRequestResponse;

typedef void(^JLCallBackBlock)(JLRequestResponse *response);

@interface JLRequestProxy : NSObject

+ (instancetype)sharedInstance;

- (NSInteger)requestWithMethod:(NSString *)method
                       request:(JLRequest *)request
                       success:(JLCallBackBlock)success
                          fail:(JLCallBackBlock)fail;

- (void)cancelRequestWithRequestID:(NSNumber *)requestID;

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

@end
