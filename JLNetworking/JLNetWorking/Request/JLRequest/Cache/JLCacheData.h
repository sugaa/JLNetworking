//
//  JLCacheData.h
//  JLNetworking
//
//  Created by qmg on 2018/8/28.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLCacheData : NSObject<NSSecureCoding>

@property (nonatomic, assign) long long version;
@property (nonatomic, strong) NSString *sensitiveDataString;
@property (nonatomic, assign) NSStringEncoding stringEncoding;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSString *appVersionString;

@end
