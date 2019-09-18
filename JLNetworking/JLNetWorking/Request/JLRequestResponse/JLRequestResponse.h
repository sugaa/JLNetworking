//
//  JLRequestResponse.h
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLEnumType.h"

@interface JLRequestResponse : NSObject

/**
 * 响应状态
 */
@property (nonatomic, assign, readonly) JLResponseStatus status;

/**
 * 请求返回的NSData类型数据
 */
@property (nonatomic, copy, readonly) NSData *responseData;

/**
 * 请求返回的NSString类型数据
 */
@property (nonatomic, copy, readonly) NSString *responseString;

/**
 * 请求返回的指定序列号类型数据
 */
@property (nonatomic, copy, readonly) id responseObject;

/**
 * 对应的请求ID
 */
@property (nonatomic, assign, readonly) NSInteger requestId;

/**
 * 对应的请求
 */
@property (nonatomic, copy, readonly) NSURLRequest *request;

/**
 * 对应的请求参数
 */
@property (nonatomic, copy) NSDictionary *requestParams;

/**
 * 用于获取responseString的编码类型
 */
@property (nonatomic, strong, readonly) NSHTTPURLResponse *httpResponse;


- (instancetype)initWithHttpResponse:(NSHTTPURLResponse *)httpResponse
                        responseData:(NSData *)responseData
              responseSerializerType:(JLResponseSerializerType)responseSerializerType
                           requestId:(NSNumber *)requestId
                             request:(NSURLRequest *)request
                              status:(JLResponseStatus)status;

- (instancetype)initWithHttpResponse:(NSHTTPURLResponse *)httpResponse
                        responseData:(NSData *)responseData
              responseSerializerType:(JLResponseSerializerType)responseSerializerType
                           requestId:(NSNumber *)requestId
                             request:(NSURLRequest *)request
                               error:(NSError *)error;

- (instancetype)initWithResponseData:(NSData *)responseData
              responseSerializerType:(JLResponseSerializerType)responseSerializerType
                              status:(JLResponseStatus)status;

@end
