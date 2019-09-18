//
//  JLRequestValidator.h
//  JLNetworking
//
//  Created by qmg on 2018/8/29.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JLRequest;

@protocol JLRequestValidator <NSObject>

@optional
/**
 * 验证url字段的参数(不包括公共参数)，询问是否允许验证通过
 * @param request JLRequest
 * @param data    公共参数字典
 * @return YES(验证通过) or NO(验证不通过)
 */
- (BOOL)request:(JLRequest *)request verifyWithParamsData:(NSDictionary *)data;

/**
 * 验证请求回来的数据（仅该url的request），询问是否允许验证通过
 * @param request JLRequest
 * @param data    返回的字典数据
 * @return YES(验证通过) or NO(验证不通过)
 */
- (BOOL)request:(JLRequest *)request verifyWithCallBackData:(NSDictionary *)data;

@end
