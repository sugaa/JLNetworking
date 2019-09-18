//
//  JLRequestResponse.m
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "JLRequestResponse.h"
#import "JLEnumType.h"
#import "NSURLRequest+JLNetworkMethods.h"
#import "NSObject+JLNetworkMethods.h"

@interface JLRequestResponse ()
@property (nonatomic, strong, readwrite) NSHTTPURLResponse *httpResponse;
@property (nonatomic, assign, readwrite) JLResponseStatus status;
@property (nonatomic, copy, readwrite) NSString *responseString;
@property (nonatomic, copy, readwrite) id responseObject;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, assign, readwrite) BOOL isCache;
@end

@implementation JLRequestResponse
#pragma mark - public methods
- (instancetype)initWithHttpResponse:(NSHTTPURLResponse *)httpResponse
                        responseData:(NSData *)responseData
              responseSerializerType:(JLResponseSerializerType)responseSerializerType
                           requestId:(NSNumber *)requestId
                             request:(NSURLRequest *)request
                              status:(JLResponseStatus)status {
    
    if (self = [super init]) {
        self.httpResponse = httpResponse;
        self.responseData = responseData;
        self.responseString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] jl_defaultValue:@""];
        self.status = status;
        self.requestId = [requestId integerValue];
        self.request = request;
        self.requestParams = request.requestParams;
        self.isCache = NO;
        
        switch (responseSerializerType) {
            case JLResponseSerializerTypeHTTP:
                self.responseObject = responseData;
                break;
            case JLResponseSerializerTypeJSON:
                if (responseData.length > 0) {
                    self.responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
                }
                break;
            case JLResponseSerializerTypeXMLParser:
                self.responseObject = [[NSXMLParser alloc] initWithData:responseData];
                break;
        }
        
        
    }
    return self;
}

- (instancetype)initWithHttpResponse:(NSHTTPURLResponse *)httpResponse
                        responseData:(NSData *)responseData
              responseSerializerType:(JLResponseSerializerType)responseSerializerType
                           requestId:(NSNumber *)requestId
                             request:(NSURLRequest *)request
                               error:(NSError *)error {
    
    if (self = [super init]) {
        
        self.httpResponse = httpResponse;
        self.responseString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] jl_defaultValue:@""];
        self.status = [self responseStatusWithError:error];
        self.requestId = [requestId integerValue];
        self.request = request;
        self.responseData = responseData;
        self.requestParams = request.requestParams;
        self.isCache = NO;
        
        if (responseData) {
            switch (responseSerializerType) {
                case JLResponseSerializerTypeHTTP:
                    self.responseObject = responseData;
                    break;
                case JLResponseSerializerTypeJSON:
                    if (responseData.length > 0) {
                        self.responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
                    }
                    break;
                case JLResponseSerializerTypeXMLParser:
                    self.responseObject = [[NSXMLParser alloc] initWithData:responseData];
                    break;
            }
        } else {
            self.responseObject = nil;
        }
    }
    return self;
}

- (instancetype)initWithResponseData:(NSData *)responseData
              responseSerializerType:(JLResponseSerializerType)responseSerializerType
                              status:(JLResponseStatus)status {
    
    if (self = [super init]) {
        self.responseString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] jl_defaultValue:@""];
        self.status = status;
        self.requestId = 0;
        self.request = nil;
        self.responseData = [responseData copy];
        self.isCache = YES;
        
        switch (responseSerializerType) {
            case JLResponseSerializerTypeHTTP:
                self.responseObject = responseData;
                break;
            case JLResponseSerializerTypeJSON:
                if (responseData.length > 0) {
                    self.responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
                }
                break;
            case JLResponseSerializerTypeXMLParser:
                self.responseObject = [[NSXMLParser alloc] initWithData:responseData];
                break;
        }
    }
    return self;
}

#pragma mark - private methods
- (JLResponseStatus)responseStatusWithError:(NSError *)error {
    if (error) {
        JLResponseStatus result = JLResponseStatusErrorNoNetwork;
        
        //除了超时以外，所有错误都当成是无网络
        if (error.code == NSURLErrorTimedOut) {
            result = JLResponseStatusErrorNoNetwork;
        }
        return result;
    } else {
        return JLResponseStatusSuccess;
    }
}

@end
