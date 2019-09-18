//
//  JLCacheData.m
//  JLNetworking
//
//  Created by qmg on 2018/8/28.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "JLCacheData.h"

@implementation JLCacheData

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.version) forKey:NSStringFromSelector(@selector(version))];
    [aCoder encodeObject:self.sensitiveDataString forKey:NSStringFromSelector(@selector(sensitiveDataString))];
    [aCoder encodeObject:@(self.stringEncoding) forKey:NSStringFromSelector(@selector(stringEncoding))];
    [aCoder encodeObject:self.creationDate forKey:NSStringFromSelector(@selector(creationDate))];
    [aCoder encodeObject:self.appVersionString forKey:NSStringFromSelector(@selector(appVersionString))];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self.version = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(version))] integerValue];
        self.sensitiveDataString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(sensitiveDataString))];
        self.stringEncoding = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(stringEncoding))] integerValue];
        self.creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(creationDate))];
        self.appVersionString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(appVersionString))];
    }
    return self;
}

@end
