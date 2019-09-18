//
//  JLRequestGenerator.h
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JLRequest;

@interface JLRequestGenerator : NSObject

+ (NSURLRequest *)generateRequestWithMethod:(NSString *)method request:(JLRequest *)request;

@end
