//
//  JLRequestProtocol.h
//  JLNetworking
//
//  Created by qmg on 2018/8/29.
//  Copyright © 2018年 NN. All rights reserved.
//

#ifndef JLRequestProtocol_h
#define JLRequestProtocol_h

#import <Foundation/Foundation.h>
#import "JLEnumType.h"

@protocol JLRequestProtocol <NSObject>

@required

/**
 * url字段
 * @return url字段
 */
- (NSString *)requestUrl;

@optional
/**
 * service
 * @return service
 */
- (NSString *)serviceType;

/**
 *  http请求类型
 *  @return 请求类型
 */
- (JLRequestType)requestType;

/**
 * 请求参数
 * @return 请求参数
 */
- (NSDictionary *)requestParams;

/**
 * 表单 参数
 * @return 表单参数
 */
- (NSDictionary *)formDataParams;

/**
 * 缓存时间(不设置默认为不缓存)
 * @return 缓存时间,秒(s)为单位
 */
- (NSInteger)cacheTimeSeconds;

/**
 * 缓存版本。该缓存的版本号，不同于APP的版本号
 * @return cacheVersion
 */
- (long long)cacheVersion;

/**
 * 可以用来告诉该条缓存是否是要更新，用来判断该条缓存是否还有效。推荐使用`NSArray` or `NSDictionary`其他类型的注意验证是否正确。
 * 比如参数不同，url相同也不要缓存就可以把请求参数作为cacheSensitiveData
 * @return cacheSensitiveData
 */
- (id)cacheSensitiveData;

/**
 * Response serializer type. See also `responseObject`.
 * @return JLResponseSerializerType
 */
- (JLResponseSerializerType)responseSerializerType;

/**
 * Whether cache is asynchronously written to storage. Default is YES.
 * @return YES or NO
 */
- (BOOL)writeCacheAsynchronously;

/**
 * 使用缓存的方式
 * @return JLUseCacheType
 */
- (JLUseCacheType)useCacheType;

/**
 * JLRequestResponse里的responseObject的序列化类型
 * @return JLRequestSerializerType
 */
- (JLRequestSerializerType)requestSerializerType;

/**
 * 超时时间，默认使用JLNetworkingConfiguration配置的超时时间（除非改api真的需要特殊处理，否则不要在自定义，不便于后期维护）
 * @return requestTimeoutInterval
 */
- (NSTimeInterval)requestTimeoutInterval;

/**
 * 服务器url账号密码授权。格式为：@[@"Username", @"Password"]
 * @return requestAuthorizationHeaderFieldArray
 */
- (NSArray<NSString *> *)requestAuthorizationHeaderFieldArray;

/**
 * 是否允许使用窝蜂数据。默认YES
 * @return YES or NO
 */
- (BOOL)allowsCellularAccess;

/**
 * 添加HTTP请求头
 * @return requestHeaderFieldValueDictionary
 */
- (NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;
/**
 * 自定义请求
 * `requestUrl`, `requestTimeoutInterval`，`requestMethod`，
 * `requestSerializerType`，`allowsCellularAccess`，`publicParams`，`apiVersion`，
 * `requestParams`，方法将被忽略。
 * @return NSURLRequest
 */
- (NSURLRequest *)buildCustomUrlRequest;

/**
 * 是否使用公共参数
 * @return YES or NO
 */
- (BOOL)isUsePublicParams;

@end

#endif /* JLRequestProtocol_h */
