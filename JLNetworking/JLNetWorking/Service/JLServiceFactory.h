//
//  JLServiceFactory.h
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLService.h"

@interface JLServiceFactory : NSObject

+ (instancetype)sharedInstance;
- (JLService<JLServiceProtocol> *)serviceWithIdentifier:(NSString *)identifier;

@end
