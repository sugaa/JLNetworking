//
//  NSObject+JLNetworkMethods.m
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "NSObject+JLNetworkMethods.h"

@implementation NSObject (JLNetworkMethods)

- (id)jl_defaultValue:(id)defaultData {
    if (![defaultData isKindOfClass:[self class]]) {
        return defaultData;
    }
    
    if ([self jl_isEmptyObject]) {
        return defaultData;
    }
    
    return self;
}

- (BOOL)jl_isEmptyObject {
    if ([self isEqual:[NSNull null]]) {
        return YES;
    }
    
    if ([self isKindOfClass:[NSString class]]) {
        if ([(NSString *)self length] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)self count] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        if ([(NSDictionary *)self count] == 0) {
            return YES;
        }
    }
    
    return NO;
}

@end
