//
//  JLRequestQueue.h
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JLRequest;

@interface JLRequestQueue : NSObject

+ (instancetype)sharedInstance;

- (void)addRequest:(JLRequest *)request key:(NSString *)key;

- (void)removeRequestWithKey:(NSString *)key;

@end
