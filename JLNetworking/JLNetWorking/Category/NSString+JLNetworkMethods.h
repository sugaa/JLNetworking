//
//  NSString+JLNetworkMethods.h
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JLNetworkMethods)

- (NSString *)jl_MD5;
+ (NSString *)jl_appVersionString;
+ (NSString *)jl_dictionaryToJson:(NSDictionary *)dic;
+ (NSStringEncoding)jl_stringEncodingWithResponse:(NSHTTPURLResponse *)response;

@end
