//
//  JLEnumType.h
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * HTTP请求方法类型
 */
typedef NS_ENUM (NSUInteger, JLRequestType){
    JLRequestTypeGet,
    JLRequestTypePost,
    JLRequestTypePut,
    JLRequestTypeDelete,
    JLRequestTypeHead,
    JLRequestTypePatch,
};

/**
 * JLRequestResponse里的responseObject的序列化类型
 */
typedef NS_ENUM(NSInteger, JLResponseSerializerType) {
    //NSData type
    JLResponseSerializerTypeHTTP,
    //JSON object type
    JLResponseSerializerTypeJSON,
    //NSXMLParser type
    JLResponseSerializerTypeXMLParser,
};

/**
 * 使用缓存的方式
 */
typedef NS_ENUM(NSInteger, JLUseCacheType) {
    //默认状态：请求前，不使用缓存数据。
    JLUseCacheTypeDefault,
    //请求前，预先使用缓存数据。
    JLUseCacheTypeBefore,
    //先请求，如果请求失败 再使用缓存 数据(默认 开启 缓存)
    JLUseCacheTypeAfterRequest,
};

/**
 * requestSerializer type
 */
typedef NS_ENUM(NSInteger, JLRequestSerializerType) {
    JLRequestSerializerTypeHTTP,
    JLRequestSerializerTypeJSON,
};

/**
 * request请求返回的状态
 */
typedef NS_ENUM (NSUInteger, JLRequestResultType){
    //没有产生过API请求，这个是Request的默认状态。
    JLRequestResultTypeDefault,
    //API请求成功且返回数据正确，此时Request的数据是可以直接拿来使用的。
    JLRequestResultTypeSuccess,
    //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，Request的状态就会是这个。
    JLRequestResultTypeNoContent,
    //参数错误，此时Request不会调用API，因为参数验证是在调用API之前做的。
    JLRequestResultTypeParamsError,
    //请求超时。
    JLRequestResultTypeTimeout,
    //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
    JLRequestResultTypeNoNetWork
};

/**
 * API的响应状态
 */
typedef NS_ENUM(NSUInteger, JLResponseStatus) {
    //请求成功，真正发起网络请求
    JLResponseStatusSuccess,
    //请求成功，读取有效的缓存
    JLResponseStatusSuccessCache,
    //请求成功，读取过期的缓存
    JLResponseStatusSuccessExpireCache,
    //超时
    JLResponseStatusErrorTimeout,
    //默认除了超时以外的错误都是无网络错误
    JLResponseStatusErrorNoNetwork
};

//缓存错误类型
typedef NS_ENUM(NSInteger, JLRequestCacheError) {
    //过期
    JLRequestCacheErrorExpired = -1,
    //版本号不对
    JLRequestCacheErrorVersionMismatch = -2,
    //验证标志不对
    JLRequestCacheErrorSensitiveDataMismatch = -3,
    //APP版本不对
    JLRequestCacheErrorAppVersionMismatch = -4,
    //缓存时间无效（<0）
    JLRequestCacheErrorInvalidCacheTime = -5,
    //缓存验证体不通过
    JLRequestCacheErrorInvalidMetadata = -6,
    //无效的缓存数据
    JLRequestCacheErrorInvalidCacheData = -7,
};

