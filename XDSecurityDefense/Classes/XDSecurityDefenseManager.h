//
//  XDSecurityDefenseManager.h
//  Pods
//
//  Created by 施孝达 on 2018/6/9.
//

#import <Foundation/Foundation.h>

@interface XDSecurityDefenseManager : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (void)initWithClassPrefix:(NSArray <NSString *> *)classPrefixArray ignoreFragment:(NSArray <NSString *>*)fragments;

@end
