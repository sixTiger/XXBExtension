//
//  NSObject+XXBClass.m
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/9.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import "NSObject+XXBClass.h"
#import <objc/runtime.h>
#import "XXBFoundation.h"
#import "NSObject+XXBKeyValue.h"
#import "NSObject+XXBCoding.m"

static const char XXBAllowedPropertyNamesKey = '\0';
static const char XXBIgnoredPropertyNamesKey = '\0';
static const char XXBAllowedCodingPropertyNamesKey = '\0';
static const char XXBIgnoredCodingPropertyNamesKey = '\0';

static NSMutableDictionary *XXBAllowedPropertyNamesDict_;
static NSMutableDictionary *XXBIgnoredPropertyNamesDict_;
static NSMutableDictionary *XXBAllowedCodingPropertyNamesDict_;
static NSMutableDictionary *XXBIgnoredCodingPropertyNamesDict_;

@implementation NSObject (XXBClass)
+ (void)load
{
    XXBAllowedPropertyNamesDict_ = [NSMutableDictionary dictionary];
    XXBIgnoredPropertyNamesDict_ = [NSMutableDictionary dictionary];
    XXBAllowedCodingPropertyNamesDict_ = [NSMutableDictionary dictionary];
    XXBIgnoredCodingPropertyNamesDict_ = [NSMutableDictionary dictionary];
}

+ (NSMutableDictionary *)dictForKey:(const void *)key
{
    @synchronized (self) {
        if (key == &XXBAllowedPropertyNamesKey) return XXBAllowedPropertyNamesDict_;
        if (key == &XXBIgnoredPropertyNamesKey) return XXBIgnoredPropertyNamesDict_;
        if (key == &XXBAllowedCodingPropertyNamesKey) return XXBAllowedCodingPropertyNamesDict_;
        if (key == &XXBIgnoredCodingPropertyNamesKey) return XXBIgnoredCodingPropertyNamesDict_;
        return nil;
    }
}

+ (void)XXB_enumerateClasses:(XXBClassesEnumeration)enumeration
{
    if (enumeration == nil) {
        return;
    }
    BOOL stop = NO;
    
    Class c = self;
    while (c && !stop) {
        enumeration(c,&stop);
        c = class_getSuperclass(c);
        if ([XXBFoundation isClassFromFoundation:c]) {
            break;
        }
    }
}

+ (void)XXB_enumerateAllClasses:(XXBClassesEnumeration)enumeration
{
    if (enumeration == nil) {
        return;
    }
    BOOL stop = NO;
    
    Class c = self;
    while (c && !stop) {
        enumeration(c,&stop);
        c = class_getSuperclass(c);
        if ([XXBFoundation isClassFromFoundation:c]) {
            break;
        }
    }
}

#pragma mark - 属性黑名单配置

+ (void)XXB_setupIgnoredPropertyNames:(XXBIgnoredPropertyNames)ignoredPropertyNames
{
    [self XXB_setupBlockReturnValue:ignoredPropertyNames key:&XXBIgnoredPropertyNamesKey];
}

+ (NSMutableArray *)XXB_totalIgnoredPropertyNames
{
    return [self XXB_totalObjectsWithSelector:@selector(XXB_ignoredPropertyNames) key:&XXBIgnoredPropertyNamesKey];
}

#pragma mark - 归档属性黑名单配置
+ (void)XXB_setupIgnoredCodingPropertyNames:(XXBIgnoredCodingPropertyNames)ignoredCodingPropertyNames
{
    [self XXB_setupBlockReturnValue:ignoredCodingPropertyNames key:&XXBIgnoredCodingPropertyNamesKey];
}

+ (NSMutableArray *)XXB_totalIgnoredCodingPropertyNames
{
    return [self XXB_totalObjectsWithSelector:@selector(XXB_ignoredCodingPropertyNames) key:&XXBIgnoredCodingPropertyNamesKey];
}

#pragma mark - 属性白名单配置
+ (void)XXB_setupAllowedPropertyNames:(XXBAllowedPropertyNames)allowedPropertyNames;
{
    [self XXB_setupBlockReturnValue:allowedPropertyNames key:&XXBAllowedPropertyNamesKey];
}

+ (NSMutableArray *)XXB_totalAllowedPropertyNames
{
    return [self XXB_totalObjectsWithSelector:@selector(XXB_allowedPropertyNames) key:&XXBAllowedPropertyNamesKey];
}

#pragma mark - 归档属性白名单配置
+ (void)XXB_setupAllowedCodingPropertyNames:(XXBAllowedCodingPropertyNames)allowedCodingPropertyNames
{
    [self XXB_setupBlockReturnValue:allowedCodingPropertyNames key:&XXBAllowedCodingPropertyNamesKey];
}

+ (NSMutableArray *)XXB_totalAllowedCodingPropertyNames
{
    return [self XXB_totalObjectsWithSelector:@selector(XXB_allowedCodingPropertyNames) key:&XXBAllowedCodingPropertyNamesKey];
}

#pragma mark - block和方法处理:存储block的返回值
+ (void)XXB_setupBlockReturnValue:(id (^)())block key:(const char *)key
{
    if (block) {
        objc_setAssociatedObject(self, key, block(), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // 清空数据
    [[self dictForKey:key] removeAllObjects];
}

+ (NSMutableArray *)XXB_totalObjectsWithSelector:(SEL)selector key:(const char *)key
{
    NSMutableArray *array = [self dictForKey:key][NSStringFromClass(self)];
    if (array) return array;
    
    // 创建、存储
    [self dictForKey:key][NSStringFromClass(self)] = array = [NSMutableArray array];
    
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSArray *subArray = [self performSelector:selector];
#pragma clang diagnostic pop
        if (subArray) {
            [array addObjectsFromArray:subArray];
        }
    }
    
    [self XXB_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        NSArray *subArray = objc_getAssociatedObject(c, key);
        [array addObjectsFromArray:subArray];
    }];
    return array;
}

@end
