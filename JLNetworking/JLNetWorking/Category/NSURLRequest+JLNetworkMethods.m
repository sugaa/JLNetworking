//
//  NSURLRequest+JLNetworkMethods.m
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "NSURLRequest+JLNetworkMethods.h"

#import <objc/runtime.h>

static void *JLNetworkingRequestParams;

static void *JLNetworkingFormDataParams;

@implementation NSURLRequest (JLNetworkMethods)

- (void)setRequestParams:(NSDictionary *)requestParams {
    objc_setAssociatedObject(self, &JLNetworkingRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)requestParams {
    return objc_getAssociatedObject(self, &JLNetworkingRequestParams);
}

- (void)setFormDataParams:(NSDictionary *)formDataParams {
    objc_setAssociatedObject(self, &JLNetworkingFormDataParams, formDataParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)formDataParams {
    return objc_getAssociatedObject(self, &JLNetworkingFormDataParams);
}

@end
