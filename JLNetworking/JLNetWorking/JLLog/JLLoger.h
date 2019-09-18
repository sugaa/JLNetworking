//
//  JLLoger.h
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLRequestResponse.h"

FOUNDATION_EXPORT void JLLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@interface JLLoger : NSObject

+ (void)logDebugInfoWithRequest:(NSURLRequest *)request
              serviceIdentifier:(NSString *)serviceIdentifier
                     methodName:(NSString *)methodName
                     httpMethod:(NSString *)httpMethod;

+ (void)logDebugInfoWithResponse:(NSHTTPURLResponse *)response
                     resposeData:(NSData *)resposeData
                         request:(NSURLRequest *)request
                           error:(NSError *)error;

+ (void)logDebugInfoWithCachedResponse:(JLRequestResponse *)response
                     serviceIdentifier:(NSString *)serviceIdentifier
                            methodName:(NSString *)methodName;

+ (void)logDeBugWithTitle:(NSString *)title;

@end
