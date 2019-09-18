//
//  NSMutableString+JLNetworkMethods.h
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (JLNetworkMethods)

- (void)jl_appendURLRequest:(NSURLRequest *)request;

@end
