//
//  JLRequest.h
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLRequestProtocol.h"
#import "JLRequestCallBackDelegate.h"
#import "JLRequestValidator.h"
#import "JLEnumType.h"

@class JLRequestResponse;

//在调用成功之后的params字典里面，用这个key可以取出requestID
static NSString * const kJLBaseRequestID = @"kJLBaseRequestID";

@class JLRequest;

typedef void(^JLRequestCompletionBlock)(JLRequest *request);

@interface JLRequest : NSObject

/**
 * 子类要遵循的协议
 */
@property (nonatomic, weak) id<JLRequestProtocol> protocol;

/**
 * 请求完成的回调
 */
@property (nonatomic, weak) id<JLRequestCallBackDelegate> delegate;

/**
 验证器协议
 */
@property (nonatomic, weak) id<JLRequestValidator> validator;

/**
 * 请求返回的数据
 */
@property (nonatomic, strong) JLRequestResponse *response;

/**
 * 是否加载中,可以用于避免重复发起请求。
 */
@property (nonatomic, assign, readonly) BOOL isLoading;

/**
 * request请求返回的状态类型，JLRequestResultTypeSuccess可以直接使用response。
 * 如果请求失败，子类的useCacheType为JLUseCacheTypeBefore，即允许使用过期缓存，response也是可以直接使用。
 */
@property (nonatomic, readwrite) JLRequestResultType requestResultType;

/**
 * block发起请求
 */
- (NSInteger)startWithCompletionBlock:(JLRequestCompletionBlock)completionBlock;

/**
 * delegate发起请求
 */
- (NSInteger)start;

/**
 * 取消该url的所有请求
 */
- (void)cancelAllRequests;

/**
 * 根据requestID取消该url的指定请求
 * @param requestID 请求ID，每次发起请求时会返回一个唯一的请求ID
 */
- (void)cancelRequestWithRequestId:(NSInteger)requestID;

/**
 * 清除该URL的缓存数据
 */
- (void)cleanReqeustCache;

/**
 * 清除该URL的沙盒缓存数据
 */
- (void)clearCache;

/**
 * 清除沙盒所有缓存数据
 */
- (void)clearAllCache;


@end
