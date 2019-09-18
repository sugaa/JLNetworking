//
//  JLService.h
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JLService;

// 所有的Service继承类都要遵循这个协议
@protocol JLServiceProtocol <NSObject>

@required

/**
 * 主址URL
 */
@property (nonatomic, readonly) NSString *apiBaseUrl;

@optional

/**
 * 公共参数
 */
@property (nonatomic, readonly) NSDictionary *apiPublicParams;

/**
 * url版本号
 */
@property (nonatomic, readonly) NSString *apiVersion;

/**
 * 添加HTTP请求头
 * @return requestHeaderFieldValueDictionary
 */
- (NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;

@end

// service验证器
@protocol JLServiceValidator <NSObject>

@optional
/**
 * 验证该service下的公共参数
 * @param service service
 * @param data    公共参数字典
 * @return YES(验证通过) or NO(验证不通过)
 */
- (BOOL)service:(JLService *)service verifyWithParamsData:(NSDictionary *)data;

/**
 * service级别验证返回的数据，使用该service下所有的request都会这个函数里面进行检查
 * @param service service
 * @param data    返回的字典数据
 * @return YES(验证通过) or NO(验证不通过)
 */
- (BOOL)service:(JLService *)service verifyWithCallBackData:(NSDictionary *)data;

@end

@interface JLService : NSObject

/**
 * 主址
 */
@property (nonatomic, strong, readonly) NSString *baseUrl;

/**
 * 公共参数
 */
@property (nonatomic, strong, readonly) NSDictionary *publicParams;

/**
 * URL版本号
 */
@property (nonatomic, strong, readonly) NSString *version;

/**
 * JLService子类
 */
@property (nonatomic, weak) id<JLServiceProtocol> protocol;

/**
 * 验证器
 */
@property (nonatomic, weak) id<JLServiceValidator> validator;

@end
