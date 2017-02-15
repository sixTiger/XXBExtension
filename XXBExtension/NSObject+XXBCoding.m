//
//  NSObject+XXBCoding.m
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/13.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import "NSObject+XXBCoding.h"
#import "NSObject+XXBProperty.h"
#import "NSObject+XXBClass.h"

@implementation NSObject(XXBCoding)
- (void)XXB_encode:(NSCoder *)encoder
{
    Class clazz = [self class];
    
    NSArray *allowedCodingPropertyNames = [clazz XXB_totalAllowedCodingPropertyNames];
    NSArray *ignoredCodingPropertyNames = [clazz XXB_totalIgnoredCodingPropertyNames];
    
    [clazz XXB_enumerateProperties:^(XXBProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if (allowedCodingPropertyNames.count && ![allowedCodingPropertyNames containsObject:property.name]) return;
        if ([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        id value = [property valueForObject:self];
        if (value == nil) return;
        [encoder encodeObject:value forKey:property.name];
    }];
}

- (void)XXB_decode:(NSCoder *)decoder
{
    Class clazz = [self class];
    
    NSArray *allowedCodingPropertyNames = [clazz XXB_totalAllowedCodingPropertyNames];
    NSArray *ignoredCodingPropertyNames = [clazz XXB_totalIgnoredCodingPropertyNames];
    
    [clazz XXB_enumerateProperties:^(XXBProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if (allowedCodingPropertyNames.count && ![allowedCodingPropertyNames containsObject:property.name]) return;
        if ([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        id value = [decoder decodeObjectForKey:property.name];
        if (value == nil) { // 兼容以前的XXBExtension版本
            value = [decoder decodeObjectForKey:[@"_" stringByAppendingString:property.name]];
        }
        if (value == nil) return;
        [property setValue:value forObject:self];
    }];
}

@end
