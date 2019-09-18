//
//  NSURLRequest+JLNetworkMethods.h
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (JLNetworkMethods)

@property (nonatomic, copy) NSDictionary *requestParams;

@property (nonatomic, copy) NSDictionary *formDataParams;

@end
