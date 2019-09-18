//
//  NSMutableString+JLNetworkMethods.m
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "NSMutableString+JLNetworkMethods.h"
#import "NSURLRequest+JLNetworkMethods.h"
#import "NSObject+JLNetworkMethods.h"

@implementation NSMutableString (JLNetworkMethods)

- (void)jl_appendURLRequest:(NSURLRequest *)request {
    [self appendFormat:@"\n\nHTTP URL:\n\t%@", request.URL];
    [self appendFormat:@"\n\nHTTP RequestParams:\n\t%@", request.requestParams];
    [self appendFormat:@"\n\nHTTP FormataParams:\n\t%@", request.formDataParams];
    [self appendFormat:@"\n\nHTTP Header:\n%@", request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @"\t\t\t\t\tN/A"];
    [self appendFormat:@"\n\nHTTP Body:\n\t%@\n\n", [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] jl_defaultValue:@"\t\t\t\tN/A"]];
}

@end
