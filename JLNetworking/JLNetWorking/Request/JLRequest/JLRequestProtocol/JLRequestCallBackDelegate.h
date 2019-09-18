//
//  JLRequestCallBackDelegate.h
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JLRequest;

@protocol JLRequestCallBackDelegate <NSObject>

@required
/**
 * 请求完成的回调
 * @param request JLRequest
 */
- (void)requestCallAPIDidCompletion:(JLRequest *)request;

@end

