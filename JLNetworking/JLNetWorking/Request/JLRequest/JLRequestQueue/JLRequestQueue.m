//
//  JLRequestQueue.m
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "JLRequestQueue.h"
#import "JLRequest.h"

@interface JLRequestQueue ()

@property (nonatomic, strong) NSMutableDictionary *requestDic;

@end

@implementation JLRequestQueue

#pragma mark - life cycle
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static JLRequestQueue *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JLRequestQueue alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addRequest:(JLRequest *)request
               key:(NSString *)key {
    @synchronized(self) {
        [_requestDic setObject:request forKey:key];
    }
}

- (void)removeRequestWithKey:(NSString *)key {
    @synchronized(self) {
        [_requestDic removeObjectForKey:key];
    }
}

@end
