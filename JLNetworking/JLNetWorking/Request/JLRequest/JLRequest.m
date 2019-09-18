//
//  JLRequest.m
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "JLRequest.h"
#import "JLLoger.h"
#import "JLServiceFactory.h"
#import "JLRequestProxy.h"
#import "JLRequestQueue.h"
#import "JLCacheData.h"
#import "NSURLRequest+JLNetworkMethods.h"
#import "NSString+JLNetworkMethods.h"
#import "AFNetworkReachabilityManager.h"
#import "JLNetWorkConfiguration.h"

#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_With_QoS_Available 1140.11
#else
#define NSFoundationVersionNumber_With_QoS_Available NSFoundationVersionNumber_iOS_8_0
#endif

NSString *const JLRequestCacheErrorDomain = @"com.jl.request.caching";

NSString * const kJLCompletionBlockKey = @"kJLCompletionBlockKey";

static dispatch_queue_t jlrequest_cache_writing_queue() {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_attr_t attr = DISPATCH_QUEUE_SERIAL;//串行队列
        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_With_QoS_Available) {
            attr = dispatch_queue_attr_make_with_qos_class(attr, QOS_CLASS_BACKGROUND, 0);
        }
        queue = dispatch_queue_create("com.jl.jlrequest.caching", attr);
    });
    
    return queue;
}

@interface JLRequest()

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) NSMutableArray *requestIdList;
@property (nonatomic, strong) NSMutableDictionary *completionBlockMutableDic;
@property (nonatomic, strong) id fetchedRawData;

@property (nonatomic, strong, readwrite) NSData *cacheData;
@property (nonatomic, strong, readwrite) JLCacheData *jlCacheData;

/**
 是否发起依赖请求，是就会忽略过期缓存的回调
 */
@property (nonatomic, assign) BOOL ignoreCache;

@end

@implementation JLRequest

#pragma mark --- life cycle

+ (void)load {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (instancetype)init {
    if (self = [super init]) {
        
        _protocol = nil;
        _fetchedRawData = nil;
        _requestResultType = JLRequestResultTypeDefault;
        
        if ([self conformsToProtocol:@protocol(JLRequestProtocol)]) {
            self.protocol = (id <JLRequestProtocol>)self;
        } else {
            NSException *exception = [[NSException alloc] initWithName:@"子类必须遵循<JLRequestProtocol>" reason:[NSString stringWithFormat:@"%@必须遵循<JLRequestProtocol>",NSStringFromClass([self class])] userInfo:nil];
            @throw exception;
        }
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return self;
}

- (void)dealloc {
    [self cancelAllRequests];
    self.requestIdList = nil;
}

#pragma mark --- Public Method

- (NSInteger)startWithCompletionBlock:(JLRequestCompletionBlock)completionBlock {
    //缓存，没有发起真正的请求时占用
    [self addCompletionBlock:completionBlock
                         key:[NSString stringWithFormat:@"%@%ld", kJLCompletionBlockKey,  (long)0]];
    NSInteger requestId = [self start];
    [self addCompletionBlock:completionBlock
                         key:[NSString stringWithFormat:@"%@%ld", kJLCompletionBlockKey, (long)requestId]];
    //移除：缓存，没有发起真正的请求时占用
    NSString *key = [NSString stringWithFormat:@"%@%ld", kJLCompletionBlockKey, (long)0];
    JLRequestCompletionBlock completionBlockFlag = [self.completionBlockMutableDic objectForKey:key];
    if (completionBlockFlag) {
        completionBlockFlag = nil;
        [self.completionBlockMutableDic removeObjectForKey:key];
    }
    [[JLRequestQueue sharedInstance] removeRequestWithKey:key];
    
    return requestId;
}

- (NSInteger)start {
    NSInteger requestId = [self loadDataWithParams:self.protocol.requestParams];
    return requestId;
}

- (void)cancelAllRequests {
    [[JLRequestProxy sharedInstance] cancelRequestWithRequestIDList:self.requestIdList];
    [self.requestIdList removeAllObjects];
    [self clearCompletionBlock];
}

- (void)cancelRequestWithRequestId:(NSInteger)requestID {
    [self removeRequestIdWithRequestID:requestID];
    [[JLRequestProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
    
    NSString *key = [NSString stringWithFormat:@"%@%ld", kJLCompletionBlockKey, (long)requestID];
    JLRequestCompletionBlock completionBlock = [self.completionBlockMutableDic objectForKey:key];
    completionBlock = nil;
    [self.completionBlockMutableDic removeObjectForKey:key];
    [[JLRequestQueue sharedInstance] removeRequestWithKey:key];
}

- (void)cleanReqeustCache {
    self.fetchedRawData = nil;
    [self clearCache];
}

- (void)clearCompletionBlock {
    for (id key in self.completionBlockMutableDic) {
        JLRequestCompletionBlock completionBlock = [self.completionBlockMutableDic objectForKey:key];
        completionBlock = nil;
        [self.completionBlockMutableDic removeObjectForKey:key];
        [[JLRequestQueue sharedInstance] removeRequestWithKey:key];
    }
}

#pragma mark - load data
- (NSInteger)loadDataWithParams:(NSDictionary *)params {
    
    NSInteger requestId = 0;
    NSDictionary *apiParams = params;
    
    //验证器
    BOOL  isCorrectParams = YES;
    if (self.validator && [self.validator respondsToSelector:@selector(request:verifyWithParamsData:)]) {
        if (![self.validator request:self verifyWithParamsData:apiParams]) {
            isCorrectParams = NO;
        }
    }
    
    JLService *service = [[JLServiceFactory sharedInstance] serviceWithIdentifier:self.protocol.serviceType];
    if (service.validator && [service.validator respondsToSelector:@selector(service:verifyWithParamsData:)]) {
        if (![service.validator service:service verifyWithParamsData:apiParams]) {
            isCorrectParams = NO;
        }
    }
    
    if (isCorrectParams) {
        switch ([self.protocol useCacheType]) {
            case JLUseCacheTypeDefault:
                if ([self loadCacheWithError:nil isIgnore:NO]) {
                    [self loadCacheWithParams:apiParams isLoadCache:NO];
                    return requestId;
                }
                break;
            case JLUseCacheTypeBefore:
                
                if ([self loadCacheWithError:nil isIgnore:YES]) {
                    
                    if (!self.ignoreCache) {
                        [self loadCacheWithParams:apiParams isLoadCache:YES];
                    }
                }
                break;
            case JLUseCacheTypeAfterRequest:
                //            // 没 网络 情况 下 直接 使用 缓存
                if ([self isReachable] == NO) {
                    if ([self loadCacheWithError:nil isIgnore:YES]) {
                        if (!self.ignoreCache) {
                            [self loadCacheWithParams:apiParams isLoadCache:YES];
                        }
                    }
                    
                }
                break;
        }
        
        
        if ([self isReachable]) {//网络
            self.isLoading = YES;
            switch (self.protocol.requestType) {
                case JLRequestTypeGet:
                    requestId = [self requestWithMethod:@"GET"];
                    break;
                case JLRequestTypePost:
                    requestId = [self requestWithMethod:@"POST"];
                    break;
                case JLRequestTypePut:
                    requestId = [self requestWithMethod:@"PUT"];
                    break;
                case JLRequestTypeDelete:
                    requestId = [self requestWithMethod:@"DELETE"];
                    break;
                case JLRequestTypeHead:
                    requestId = [self requestWithMethod:@"HEAD"];
                    break;
                case JLRequestTypePatch:
                    requestId = [self requestWithMethod:@"PATCH"];
                    break;
                default:
                    break;
            }
            
            NSMutableDictionary *dic = [apiParams mutableCopy];
            dic[kJLBaseRequestID] = @(requestId);
            
        } else {//网络
            [self failedOnCallingAPI:nil withErrorType:JLRequestResultTypeNoNetWork isLoadCache:NO];
        }
    } else {
        [self failedOnCallingAPI:nil withErrorType:JLRequestResultTypeParamsError isLoadCache:NO];
    }
    
    return requestId;
}

- (NSInteger)requestWithMethod:(NSString *)method {
    NSInteger requestID = [[JLRequestProxy sharedInstance] requestWithMethod:method request:self success:^(JLRequestResponse *response) {
        [self successedOnCallingAPI:response isLoadCache:NO];
    } fail:^(JLRequestResponse *response) {
        if ([self.protocol useCacheType] == JLUseCacheTypeAfterRequest) {
            [self loadCacheWithParams:self.protocol.requestParams isLoadCache:YES];
        } else {
            [self failedOnCallingAPI:response withErrorType:JLRequestResultTypeDefault isLoadCache:NO];
        }
    }];
    [self.requestIdList addObject:@(requestID)];
    return requestID;
}

#pragma mark - load cache

- (void)loadCacheWithParams:(NSDictionary *)params isLoadCache:(BOOL)isLoadCache {
    
    JLService *service = [[JLServiceFactory sharedInstance] serviceWithIdentifier:self.protocol.serviceType];
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
    [requestParams addEntriesFromDictionary:service.publicParams];
    [requestParams addEntriesFromDictionary:self.protocol.requestParams];
    
    JLRequestResponse *response = [[JLRequestResponse alloc] initWithResponseData:self.cacheData responseSerializerType:self.protocol.responseSerializerType status:isLoadCache ? JLResponseStatusSuccessExpireCache : JLResponseStatusSuccessCache];
    response.requestParams = requestParams;
    
    [JLLoger logDebugInfoWithCachedResponse:response
                           serviceIdentifier:self.protocol.serviceType
                                  methodName:self.protocol.requestUrl];
    
    [self successedOnCallingAPI:response isLoadCache:isLoadCache];
}

#pragma mark - api callbacks
- (void)successedOnCallingAPI:(JLRequestResponse *)response
                  isLoadCache:(BOOL)isLoadCache {
    
    if (response.responseObject) {
        self.fetchedRawData = [response.responseObject copy];
    }
    
    if (!isLoadCache) {
        self.isLoading = NO;
        [self removeRequestIdWithRequestID:response.requestId];
    }
    
    self.response = response;
    
    //验证器
    BOOL  isCorrectResponse = YES;
    if (self.validator && [self.validator respondsToSelector:@selector(request:verifyWithCallBackData:)]) {
        if (![self.validator request:self verifyWithCallBackData:response.responseObject]) {
            isCorrectResponse = NO;
        }
    }
    JLService *service = [[JLServiceFactory sharedInstance] serviceWithIdentifier:self.protocol.serviceType];
    if (service.validator && [service.validator respondsToSelector:@selector(service:verifyWithCallBackData:)]) {
        if (![service.validator service:service verifyWithCallBackData:response.responseObject]) {
            isCorrectResponse = NO;
        }
    }
    
    if (isCorrectResponse) {
        if ((self.protocol.cacheTimeSeconds >= 0 && response.status == JLResponseStatusSuccess)
            || ([self.protocol useCacheType] == JLUseCacheTypeAfterRequest && response.status == JLResponseStatusSuccess)) {
            [self saveResponseData:response.responseData];
        }
        
        self.requestResultType = JLRequestResultTypeSuccess;
        
        [self.delegate requestCallAPIDidCompletion:self];
        
        NSUInteger requestId = (long)response.requestId;
        if (response == nil) {
            requestId = 0;
        }
        NSString *key = [NSString stringWithFormat:@"%@%ld", kJLCompletionBlockKey, requestId];
        JLRequestCompletionBlock completionBlock = [self.completionBlockMutableDic objectForKey:key];
        if (completionBlock) {
            completionBlock(self);
        }
    } else { //验证器
        [self failedOnCallingAPI:response withErrorType:JLRequestResultTypeNoContent isLoadCache:isLoadCache];
    }
    
    if (!isLoadCache) {
        //移除block
        NSString *key = [NSString stringWithFormat:@"%@%ld", kJLCompletionBlockKey, (long)response.requestId];
        JLRequestCompletionBlock completionBlock = [self.completionBlockMutableDic objectForKey:key];
        if (!isLoadCache) {
            completionBlock = nil;
            [self.completionBlockMutableDic removeObjectForKey:key];
            [[JLRequestQueue sharedInstance] removeRequestWithKey:key];
        }
    }
}
- (void)failedOnCallingAPI:(JLRequestResponse *)response
             withErrorType:(JLRequestResultType)errorType
               isLoadCache:(BOOL)isLoadCache {
    
    if (isLoadCache) {
        return;
    }
    
    self.isLoading = NO;
    self.response = response;
    self.requestResultType = errorType;
    [self removeRequestIdWithRequestID:response.requestId];
    
    //delegate
    [self.delegate requestCallAPIDidCompletion:self];
    
    //block
    NSUInteger requestId = (long)response.requestId;
    if (response == nil) {
        requestId = 0;
    }
    NSString *key = [NSString stringWithFormat:@"%@%ld", kJLCompletionBlockKey, requestId];
    JLRequestCompletionBlock completionBlock = [self.completionBlockMutableDic objectForKey:key];
    if (completionBlock) {
        completionBlock(self);
    }
    
    //移除block
    if (!isLoadCache) {
        NSString *key = [NSString stringWithFormat:@"%@%ld", kJLCompletionBlockKey, (long)response.requestId];
        JLRequestCompletionBlock completionBlock = [self.completionBlockMutableDic objectForKey:key];
        if (!isLoadCache) {
            completionBlock = nil;
            [self.completionBlockMutableDic removeObjectForKey:key];
            [[JLRequestQueue sharedInstance] removeRequestWithKey:key];
        }
    }
}

#pragma mark --- requestId

- (void)removeRequestIdWithRequestID:(NSInteger)requestId {
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIdList) {
        if ([storedRequestId integerValue] == requestId) {
            requestIDToRemove = storedRequestId;
        }
    }
    if (requestIDToRemove) {
        [self.requestIdList removeObject:requestIDToRemove];
    }
}

- (void)addCompletionBlock:(JLRequestCompletionBlock)completionBlock key:(NSString *)key{
    [self.completionBlockMutableDic setObject:completionBlock
                                    forKey:key];
    [[JLRequestQueue sharedInstance] addRequest:self
                                                key:key];
}

#pragma mark --- Cache

- (BOOL)loadCacheWithError:(NSError * _Nullable __autoreleasing *)error
                  isIgnore:(BOOL)isIgnore {

    // Make sure cache time in valid.
    if ([self.protocol useCacheType] != JLUseCacheTypeAfterRequest && self.protocol.cacheTimeSeconds < 0) {
        if (error) {
            *error = [NSError errorWithDomain:JLRequestCacheErrorDomain
                                         code:JLRequestCacheErrorInvalidCacheTime
                                     userInfo:@{NSLocalizedDescriptionKey:@"Invalid cache time"}];
        }
        return NO;
    }
    
    // Try load metadata.
    if (![self loadCacheMetadata]) {
        if (error) {
            *error = [NSError errorWithDomain:JLRequestCacheErrorDomain
                                         code:JLRequestCacheErrorInvalidMetadata
                                     userInfo:@{NSLocalizedDescriptionKey:@"Invalid metadata. Cache may not exist"}];
        }
        return NO;
    }
    
    // Check if cache is still valid.
    if (![self validateCacheWithError:error isIgnore:(BOOL)isIgnore]) {
        return NO;
    }
    
    // Try load cache.
    if (![self loadCacheData]) {
        if (error) {
            *error = [NSError errorWithDomain:JLRequestCacheErrorDomain
                                         code:JLRequestCacheErrorInvalidCacheData
                                     userInfo:@{NSLocalizedDescriptionKey:@"Invalid cache data"}];
        }
        return NO;
    }
    
    return YES;
}
- (void)saveResponseData:(NSData *)data {
    if (self.protocol.writeCacheAsynchronously) {
        dispatch_async(jlrequest_cache_writing_queue(), ^{
            [self saveResponseDataToCacheFile:data];
        });
    }else {
        [self saveResponseDataToCacheFile:data];
    }
}

- (void)clearCache {
    NSString *path = [self cacheFilePath];
    
    NSError *err = nil;
    BOOL res;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    res = [fileManager removeItemAtPath:path error:&err];
    if (!res && err) {
        JLLog(@"Delete file error: %@", err);
    }
    res = [fileManager removeItemAtPath:[path stringByAppendingString:@".metadata"] error:&err];
    if (!res && err) {
        JLLog(@"Delete file error: %@", err);
    }
}

- (void)clearAllCache {
    NSString *path = [self cacheBasePath];
    [self clearCacheDataWithPath:path];
}


- (NSDictionary *)getCacheDictionary {
    
    NSString *path = [self cacheFilePath];
    NSDictionary *dict = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        dict = [NSJSONSerialization JSONObjectWithData:data
                                               options:NSJSONReadingMutableContainers
                                                 error:NULL];
    }
    return dict;
}

#pragma mark - ----------------------------- private method -----------------------------
- (void)saveResponseDataToCacheFile:(NSData *)data {
    
    if (data != nil) {
        @try {
            // New data will always overwrite old data.
            [data writeToFile:[self cacheFilePath] atomically:YES];
            
            JLCacheData *metadata = [[JLCacheData alloc] init];
            metadata.version = self.protocol.cacheVersion;
            metadata.sensitiveDataString = ((NSObject *)self.protocol.cacheSensitiveData).description;
            metadata.stringEncoding = [NSString jl_stringEncodingWithResponse:self.response.httpResponse];
            metadata.creationDate = [NSDate date];
            metadata.appVersionString = [NSString jl_appVersionString];
            [NSKeyedArchiver archiveRootObject:metadata toFile:[self cacheMetadataFilePath]];
        } @catch (NSException *exception) {
            JLLog(@"Save cache failed, reason = %@", exception.reason);
        }
    }
    
}

- (void)clearCacheDataWithPath:(NSString *)path {
    
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:path isDirectory:nil]) {
        return;
    }
    NSDirectoryEnumerator* enumerator = [fileManager enumeratorAtPath:path];
    NSError *err = nil;
    BOOL res;
    
    NSString* file;
    while (file = [enumerator nextObject]) {
        res = [fileManager removeItemAtPath:[path stringByAppendingPathComponent:file] error:&err];
        if (!res && err) {
            JLLog(@"Delete file error: %@", err);
        }
    }
    
}
#pragma mark - load cache
- (BOOL)loadCacheData {
    
    NSString *path = [self cacheFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        self.cacheData = data;
        return YES;
    }
    return NO;
}


- (NSString *)cacheFilePath {
    
    NSString *cacheFileName = [self cacheFileName];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}



#pragma mark - validate cache data
- (BOOL)validateCacheWithError:(NSError * _Nullable __autoreleasing *)error isIgnore:(BOOL)isIgnore{
    
    // Date
    if (!isIgnore) {
        NSDate *creationDate = self.jlCacheData.creationDate;
        NSTimeInterval duration = -[creationDate timeIntervalSinceNow];
        if (duration < 0 || duration > self.protocol.cacheTimeSeconds) {
            if (error) {
                *error = [NSError errorWithDomain:JLRequestCacheErrorDomain
                                             code:JLRequestCacheErrorExpired
                                         userInfo:@{NSLocalizedDescriptionKey:@"Cache expired"}];
            }
            return NO;
        }
    }
    
    // Version
    long long cacheVersionFileContent = self.jlCacheData.version;
    if (cacheVersionFileContent != self.protocol.cacheVersion) {
        if (error) {
            *error = [NSError errorWithDomain:JLRequestCacheErrorDomain
                                         code:JLRequestCacheErrorVersionMismatch
                                     userInfo:@{ NSLocalizedDescriptionKey:@"Cache version mismatch"}];
        }
        return NO;
    }
    // Sensitive data
    NSString *sensitiveDataString = self.jlCacheData.sensitiveDataString;
    NSString *currentSensitiveDataString = ((NSObject *)self.protocol.cacheSensitiveData).description;
    if (sensitiveDataString || currentSensitiveDataString) {
        // If one of the strings is nil, short-circuit evaluation will trigger
        if (sensitiveDataString.length != currentSensitiveDataString.length || ![sensitiveDataString isEqualToString:currentSensitiveDataString]) {
            if (error) {
                *error = [NSError errorWithDomain:JLRequestCacheErrorDomain
                                             code:JLRequestCacheErrorSensitiveDataMismatch
                                         userInfo:@{ NSLocalizedDescriptionKey:@"Cache sensitive data mismatch"}];
            }
            return NO;
        }
    }
    // App version
    NSString *appVersionString = self.jlCacheData.appVersionString;
    NSString *currentAppVersionString = [NSString jl_appVersionString];
    if (appVersionString || currentAppVersionString) {
        if (appVersionString.length != currentAppVersionString.length || ![appVersionString isEqualToString:currentAppVersionString]) {
            if (error) {
                *error = [NSError errorWithDomain:JLRequestCacheErrorDomain code:JLRequestCacheErrorAppVersionMismatch userInfo:@{ NSLocalizedDescriptionKey:@"App version mismatch"}];
            }
            return NO;
        }
    }
    return YES;
}


#pragma mark - load cache metadata
- (BOOL)loadCacheMetadata {
    NSString *path = [self cacheMetadataFilePath];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        @try {
            self.jlCacheData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            return YES;
        } @catch (NSException *exception) {
            JLLog(@"Load cache metadata failed, reason = %@", exception.reason);
            return NO;
        }
    }
    return NO;
}


- (NSString *)cacheMetadataFilePath {
    
    NSString *cacheMetadataFileName = [NSString stringWithFormat:@"%@.metadata", [self cacheFileName]];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheMetadataFileName];
    return path;
}

- (NSString *)cacheFileName {
    
    NSString *requestUrl = self.protocol.requestUrl;
    JLService *service = [[JLServiceFactory sharedInstance] serviceWithIdentifier:self.protocol.serviceType];
    NSString *baseUrl = service.baseUrl;
    NSDictionary *requestParams = self.protocol.requestParams;
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%ld Host:%@ Url:%@ Argument:%@",
                             (long)self.protocol.requestType, baseUrl, requestUrl, requestParams];
    NSString *cacheFileName = [requestInfo jl_MD5];
    return cacheFileName;
}

- (NSString *)cacheBasePath {
    
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"JLLazyRequestCache"];
    
    [self createDirectoryIfNeeded:path];
    return path;
}

- (void)createDirectoryIfNeeded:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}
- (void)createBaseDirectoryAtPath:(NSString *)path {
    NSError *error = nil;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        JLLog(@"create cache directory failed, error = %@", error);
    } else {
        [self addDoNotBackupAttribute:path];
    }
}

- (void)addDoNotBackupAttribute:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        JLLog(@"error to set do not backup attribute, error = %@", error);
    }
}

#pragma mark --- getters and setters
- (JLRequestType)requestType {
    return [JLNetWorkConfiguration sharedInstance].defaultRequestType;
}
- (NSString *)serviceType {
    return [JLNetWorkConfiguration sharedInstance].defaultServiceType;
}
- (NSMutableDictionary *)completionBlockMutableDic {
    if (_completionBlockMutableDic == nil) {
        _completionBlockMutableDic = [NSMutableDictionary dictionary];
    }
    return _completionBlockMutableDic;
}
- (NSInteger)cacheTimeSeconds {
    return [JLNetWorkConfiguration sharedInstance].cacheTimeSeconds;
}

- (JLResponseSerializerType)responseSerializerType {
    return JLResponseSerializerTypeJSON;
}

- (BOOL)isReachable {
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}

- (NSMutableArray *)requestIdList {
    if (_requestIdList == nil) {
        _requestIdList = [[NSMutableArray alloc] init];
    }
    return _requestIdList;
}

- (BOOL)isLoading {
    if (self.requestIdList.count == 0) {
        _isLoading = NO;
    }
    return _isLoading;
}
- (NSDictionary *)requestParams {
    return nil;
}

- (NSDictionary *)formDataParams {
    return nil;
}

- (long long)cacheVersion {
    return 0;
}

- (BOOL)writeCacheAsynchronously {
    return YES;
}
- (id)cacheSensitiveData {
    return nil;
}
- (JLUseCacheType)useCacheType {
    return [JLNetWorkConfiguration sharedInstance].userCacheType;
}

- (NSTimeInterval)requestTimeoutInterval {
    return [JLNetWorkConfiguration sharedInstance].networkTimeoutSeconds;
}

- (NSArray *)requestAuthorizationHeaderFieldArray {
    return nil;
}
- (BOOL)allowsCellularAccess {
    return YES;
}
- (NSDictionary *)requestHeaderFieldValueDictionary {
    return nil;
}
- (JLRequestSerializerType)requestSerializerType {
    return JLRequestSerializerTypeJSON;
}
- (NSURLRequest *)buildCustomUrlRequest {
    return nil;
}
- (BOOL)isUsePublicParams {
    return [JLNetWorkConfiguration sharedInstance].defaultIsUsePublicParams;
}

@end
