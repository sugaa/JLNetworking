//
//  NSObject+JLNetworkMethods.h
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JLNetworkMethods)

- (id)jl_defaultValue:(id)defaultData;
- (BOOL)jl_isEmptyObject;

@end
