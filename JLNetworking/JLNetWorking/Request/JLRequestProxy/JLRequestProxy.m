//
//  JLRequestProxy.m
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "JLRequestProxy.h"
#import "AFNetworking.h"
#import "JLRequest.h"
#import "JLRequestGenerator.h"
#import "JLRequestResponse.h"
#import "JLLoger.h"

@interface JLRequestProxy()

@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) NSNumber *recorderRequestId;

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation JLRequestProxy

#pragma mark - life cycle

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static JLRequestProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JLRequestProxy alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public methods

- (NSInteger)requestWithMethod:(NSString *)method
                       request:(JLRequest *)request
                       success:(JLCallBackBlock)success
                          fail:(JLCallBackBlock)fail {
    
    NSURLRequest *ulrRequest = request.protocol.buildCustomUrlRequest;
    if (ulrRequest == nil) {
        ulrRequest = [JLRequestGenerator generateRequestWithMethod:method request:request];
    }
    
    
    NSNumber *requestId = [self callApiWithRequest:ulrRequest
                                 serviceIdentifier:request.protocol.serviceType
                                        methodName:request.protocol.requestUrl
                                        httpMethod:method
                            responseSerializerType:request.protocol.responseSerializerType
                                           success:success
                                              fail:fail];
    return [requestId integerValue];
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID {
    NSURLSessionDataTask *requestOperation = self.dispatchTable[requestID];
    [requestOperation cancel];
    [self.dispatchTable removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList {
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestID:requestId];
    }
}

#pragma mark - private method
/** 这个函数存在的意义在于，如果将来要把AFNetworking换掉，只要修改这个函数的实现即可。 */
- (NSNumber *)callApiWithRequest:(NSURLRequest *)request
               serviceIdentifier:(NSString *)servieIdentifier
                      methodName:(NSString *)methodName
                      httpMethod:(NSString *)httpMethod
          responseSerializerType:(JLResponseSerializerType)responseSerializerType
                         success:(JLCallBackBlock)success
                            fail:(JLCallBackBlock)fail {
    
    [JLLoger logDebugInfoWithRequest:request
                    serviceIdentifier:servieIdentifier
                           methodName:methodName
                           httpMethod:httpMethod];
    
    // 跑到这里的block的时候，就已经是主线程了。
    __block NSURLSessionDataTask *dataTask = nil;
    __weak typeof(self) weakSelf = self;
    dataTask = [self.sessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        NSNumber *requestID = @([dataTask taskIdentifier]);
        [strongSelf.dispatchTable removeObjectForKey:requestID];
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSData *responseData = responseObject;
        [JLLoger logDebugInfoWithResponse:httpResponse
                               resposeData:responseData
                                   request:request
                                     error:error];
        if (error) {
            JLRequestResponse *JLResponse = [[JLRequestResponse alloc] initWithHttpResponse:httpResponse responseData:responseData responseSerializerType:responseSerializerType requestId:requestID request:request error:error];
            if (fail) {
                fail(JLResponse);
            }
        } else {
            JLRequestResponse *JLResponse = [[JLRequestResponse alloc] initWithHttpResponse:httpResponse responseData:responseData responseSerializerType:responseSerializerType requestId:requestID request:request status:JLResponseStatusSuccess];
            if (success) {
                success(JLResponse);
            }
        }
    }];
    NSNumber *requestId = @([dataTask taskIdentifier]);
    self.dispatchTable[requestId] = dataTask;
    [dataTask resume];
    
    return requestId;
}

#pragma mark - getters and setters

- (NSMutableDictionary *)dispatchTable {
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _sessionManager.securityPolicy.validatesDomainName = NO;
    }
    return _sessionManager;
}

@end
