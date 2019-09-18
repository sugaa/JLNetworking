//
//  JLNetWorkConfiguration.h
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLEnumType.h"

@interface JLNetWorkConfiguration : NSObject

/**
 * 设置请求缓存时间，默认为0不缓存，大于0缓存
 */
@property (nonatomic, assign) NSInteger cacheTimeSeconds;

/**
 * 设置请求缓存策略
 */
@property (nonatomic, assign) JLUseCacheType userCacheType;

/**
 * 设置打印日志开关，debug模式默认开启
 */
@property (nonatomic, assign) BOOL debugLogEnabled;

/**
 * 设置请求超时时间，默认20.0f
 */
@property (nonatomic, assign) NSTimeInterval networkTimeoutSeconds;

/**
 * 设置services的数组，子类实现serviceType时，会以JLRequest的serviceType作为类名来这里查找获取
 */
@property (nonatomic, strong) NSMutableArray *serviceArray;

/**
 * 默认的serviceType，子类不实现serviceType时，会到这里取
 */
@property (nonatomic, strong) NSString *defaultServiceType;

/**
 * 默认的requestType，子类不实现requestType时，会到这里取
 */
@property (nonatomic, assign) JLRequestType defaultRequestType;

/**
 * 是否默认使用公共参数,默认YES
 */
@property (nonatomic, assign) BOOL defaultIsUsePublicParams;

/**
 * 单例方法
 * @return JLNetWorkConfiguration
 */
+ (JLNetWorkConfiguration *)sharedInstance;

/**
 * 清除所有的请求缓存
 */
- (void)cleanAllRequestCacheData;

@end
