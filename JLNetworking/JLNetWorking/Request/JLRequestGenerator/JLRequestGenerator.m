//
//  JLRequestGenerator.m
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "JLRequestGenerator.h"
#import "AFNetworking.h"
#import "JLEnumType.h"
#import "JLService.h"
#import "JLServiceFactory.h"
#import "JLRequest.h"
#import "NSURLRequest+JLNetworkMethods.h"

@implementation JLRequestGenerator

+ (NSURLRequest *)generateRequestWithMethod:(NSString *)method request:(JLRequest *)request {
    //AFHTTPRequestSerializer
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForBaseRequest:request];
    
    //url
    JLService *service = [[JLServiceFactory sharedInstance] serviceWithIdentifier:request.protocol.serviceType];
    NSString *urlString;
    if (service.version.length != 0) {
        urlString = [NSString stringWithFormat:@"%@/%@/%@", service.baseUrl, service.version, request.protocol.requestUrl];
    } else {
        urlString = [NSString stringWithFormat:@"%@/%@", service.baseUrl, request.protocol.requestUrl];
    }
    
    //params
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
    [requestParams addEntriesFromDictionary:request.protocol.requestParams];
    if (request.protocol.isUsePublicParams) {
        [requestParams addEntriesFromDictionary:service.publicParams];
    }
    
    //request
    NSMutableURLRequest *urlRequest = nil;
    
    if ([method isEqualToString:@"POST"] && request.protocol.formDataParams) {
        urlRequest = [requestSerializer multipartFormRequestWithMethod:method URLString:urlString parameters:requestParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            for (NSString *httpHeaderField in request.protocol.formDataParams.allKeys) {
                NSString *value = request.protocol.formDataParams[httpHeaderField];
                [formData appendPartWithFormData:[value dataUsingEncoding:NSUTF8StringEncoding] name:httpHeaderField];
            }
        } error:nil];
        urlRequest.formDataParams = request.protocol.formDataParams;
    } else {
        urlRequest = [requestSerializer requestWithMethod:method
                                             URLString:urlString
                                            parameters:requestParams
                                                 error:NULL];
    }
    
    urlRequest.requestParams = requestParams;
    
    return urlRequest;
}
#pragma mark - private method
+ (AFHTTPRequestSerializer *)requestSerializerForBaseRequest:(JLRequest *)request {
    
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.protocol.requestSerializerType == JLRequestSerializerTypeHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.protocol.requestSerializerType == JLRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    requestSerializer.timeoutInterval = request.protocol.requestTimeoutInterval;
    requestSerializer.allowsCellularAccess = request.protocol.allowsCellularAccess;
    
    NSArray<NSString *> *authorizationHeaderFieldArray = request.protocol.requestAuthorizationHeaderFieldArray;
    if (authorizationHeaderFieldArray != nil) {
        [requestSerializer setAuthorizationHeaderFieldWithUsername:authorizationHeaderFieldArray.firstObject
                                                          password:authorizationHeaderFieldArray.lastObject];
    }
    
    
    //request的请求头
    NSDictionary<NSString *, NSString *> *requestHeaderFieldValueDictionary = request.protocol.requestHeaderFieldValueDictionary;
    //service的请求头
    JLService *service = [[JLServiceFactory sharedInstance] serviceWithIdentifier:request.protocol.serviceType];
    NSDictionary<NSString *, NSString *> *serviceHeaderFieldValueDictionary = service.protocol.requestHeaderFieldValueDictionary;
    if (requestHeaderFieldValueDictionary != nil) {
        for (NSString *httpHeaderField in requestHeaderFieldValueDictionary.allKeys) {
            NSString *value = requestHeaderFieldValueDictionary[httpHeaderField];
            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    } else if (serviceHeaderFieldValueDictionary != nil){
        for (NSString *httpHeaderField in serviceHeaderFieldValueDictionary.allKeys) {
            NSString *value = serviceHeaderFieldValueDictionary[httpHeaderField];
            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    return requestSerializer;
}

@end
