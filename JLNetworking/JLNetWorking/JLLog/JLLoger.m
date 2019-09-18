//
//  JLLoger.m
//  JLNetworking
//
//  Created by qmg on 2018/8/27.
//  Copyright © 2018年 NN. All rights reserved.
//

#import "JLLoger.h"
#import "JLNetWorkConfiguration.h"
#import "JLServiceFactory.h"
#import "NSObject+JLNetworkMethods.h"
#import "NSURLRequest+JLNetworkMethods.h"
#import "NSMutableString+JLNetworkMethods.h"
#import "NSString+JLNetworkMethods.h"

void JLLog(NSString *format, ...) {
#ifdef DEBUG
    if (![JLNetWorkConfiguration sharedInstance].debugLogEnabled) {
        return;
    }
    va_list argptr;
    va_start(argptr, format);
    NSLogv(format, argptr);
    va_end(argptr);
#endif
}

@implementation JLLoger

+ (void)logDebugInfoWithRequest:(NSURLRequest *)request
              serviceIdentifier:(NSString *)serviceIdentifier
                     methodName:(NSString *)methodName
                     httpMethod:(NSString *)httpMethod {
    
    if (![JLNetWorkConfiguration sharedInstance].debugLogEnabled) {
        return;
    }
    
    JLService *service = [[JLServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                       Request Start                        *\n**************************************************************\n\n"];
    [logString appendFormat:@"httpMethod:\t\t%@\n", [httpMethod jl_defaultValue:@"N/A"]];
    [logString appendFormat:@"BaseUrl Name:\t\t%@\n", [service.baseUrl jl_defaultValue:@"N/A"]];
    [logString appendFormat:@"Method:\t\t\t%@\n", [methodName jl_defaultValue:@"N/A"]];
    NSString *tmpApiVersion = service.version;
    if (service.version.length == 0) {
        tmpApiVersion  = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    }
    [logString appendFormat:@"Version:\t\t%@\n", tmpApiVersion];
    [logString appendFormat:@"Service:\t\t%@\n", [service class]];
    [logString appendFormat:@"Params:\n%@\n", [NSString jl_dictionaryToJson:request.requestParams]];
    
    //    [logString appendString:@"\n---------------  Related Request Content  --------------\n"];
    //    [logString appendURLRequest:request];
    
    
    [logString appendFormat:@"\n\n**************************************************************\n*                         Request End                        *\n**************************************************************\n\n\n\n"];
    JLLog(@"%@", logString);
    
}

+ (void)logDebugInfoWithResponse:(NSHTTPURLResponse *)response
                     resposeData:(NSData *)resposeData
                         request:(NSURLRequest *)request
                           error:(NSError *)error {
    
    if (![JLNetWorkConfiguration sharedInstance].debugLogEnabled) {
        return;
    }
    
    BOOL shouldLogError = error ? YES : NO;
    
    NSDictionary *jsonDictionary = nil;
    if (resposeData.length > 0) {
        jsonDictionary = [NSJSONSerialization JSONObjectWithData:resposeData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    }
    
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n==============================================================\n=                        API Response                        =\n==============================================================\n\n"];
    [logString jl_appendURLRequest:request];
    [logString appendFormat:@"Status:\t%ld\t(%@)\n\n", (long)response.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]];
    [logString appendFormat:@"Content:\n\t%@\n\n", jsonDictionary];
    
    if (shouldLogError) {
        [logString appendFormat:@"Error Domain:\t\t\t\t\t\t\t%@\n", error.domain];
        [logString appendFormat:@"Error Domain Code:\t\t\t\t\t\t%ld\n", (long)error.code];
        [logString appendFormat:@"Error Service Response:\t\t\t\t\t\t%@\n", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]];
        [logString appendFormat:@"Error Localized Description:\t\t\t%@\n", error.localizedDescription];
        [logString appendFormat:@"Error Localized Failure Reason:\t\t\t%@\n", error.localizedFailureReason];
        [logString appendFormat:@"Error Localized Recovery Suggestion:\t%@\n\n", error.localizedRecoverySuggestion];
    }
    
    //    [logString appendString:@"\n---------------  Related Request Content  --------------\n"];
    //    [logString appendURLRequest:request];
    
    [logString appendFormat:@"\n\n==============================================================\n=                    API Response End                        =\n==============================================================\n\n\n\n"];
    
    JLLog(@"%@", logString);
}

+ (void)logDebugInfoWithCachedResponse:(JLRequestResponse *)response
                     serviceIdentifier:(NSString *)serviceIdentifier
                            methodName:(NSString *)methodName{
    
    if (![JLNetWorkConfiguration sharedInstance].debugLogEnabled) {
        return;
    }
    
    JLService *service = [[JLServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n==============================================================\n=                      Cached Response                       =\n==============================================================\n\n"];
    
    [logString appendFormat:@"BaseUrl Name:\t\t%@\n", [service.baseUrl jl_defaultValue:@"N/A"]];
    [logString appendFormat:@"Method Name:\t%@\n", methodName];
    [logString appendFormat:@"Version:\t\t%@\n", [service.version jl_defaultValue:@"N/A"]];
    [logString appendFormat:@"Service:\t\t%@\n", [service class]];
    [logString appendFormat:@"Params:\n%@\n\n", [NSString jl_dictionaryToJson:response.requestParams]];
    [logString appendFormat:@"Content:\n\t%@\n\n", response.responseObject];
    
    [logString appendFormat:@"\n\n==============================================================\n=                 Cached Response End                        =\n==============================================================\n\n\n\n"];
    JLLog(@"%@", logString);
}

+ (void)logDeBugWithTitle:(NSString *)title {
    
    NSMutableString *logString = [NSMutableString string];
    [logString appendFormat:@"%@", @"\n##############################################################\n\n"];
    [logString appendFormat:@"\t\t\t\t\t%@\n", title];
    [logString appendFormat:@"%@", @"\n##############################################################\n\n"];
    JLLog(@"%@", logString);
}

@end
