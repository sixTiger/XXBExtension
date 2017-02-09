//
//  NSObject+XXBClass.h
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/9.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  遍历所有类的block（父类）
 */
typedef void (^XXBClassesEnumeration)(Class c, BOOL *stop);

/** 这个数组中的属性名才会进行字典和模型的转换 */
typedef NSArray * (^XXBAllowedPropertyNames)();

/** 这个数组中的属性名才会进行归档 */
typedef NSArray * (^XXBAllowedCodingPropertyNames)();

/** 这个数组中的属性名将会被忽略：不进行字典和模型的转换 */
typedef NSArray * (^XXBIgnoredPropertyNames)();

/** 这个数组中的属性名将会被忽略：不进行归档 */
typedef NSArray * (^XXBIgnoredCodingPropertyNames)();

@interface NSObject (XXBClass)

/**
 *  遍历所有的类
 */
+ (void)XXB_enumerateClasses:(XXBClassesEnumeration)enumeration;
+ (void)XXB_enumerateAllClasses:(XXBClassesEnumeration)enumeration;

#pragma mark - 属性白名单配置
/**
 *  这个数组中的属性名才会进行字典和模型的转换
 *
 *  @param allowedPropertyNames          这个数组中的属性名才会进行字典和模型的转换
 */
+ (void)XXB_setupAllowedPropertyNames:(XXBAllowedPropertyNames)allowedPropertyNames;

/**
 *  这个数组中的属性名才会进行字典和模型的转换
 */
+ (NSMutableArray *)XXB_totalAllowedPropertyNames;

#pragma mark - 属性黑名单配置
/**
 *  这个数组中的属性名将会被忽略：不进行字典和模型的转换
 *
 *  @param ignoredPropertyNames          这个数组中的属性名将会被忽略：不进行字典和模型的转换
 */
+ (void)XXB_setupIgnoredPropertyNames:(XXBIgnoredPropertyNames)ignoredPropertyNames;

/**
 *  这个数组中的属性名将会被忽略：不进行字典和模型的转换
 */
+ (NSMutableArray *)XXB_totalIgnoredPropertyNames;

#pragma mark - 归档属性白名单配置
/**
 *  这个数组中的属性名才会进行归档
 *
 *  @param allowedCodingPropertyNames          这个数组中的属性名才会进行归档
 */
+ (void)XXB_setupAllowedCodingPropertyNames:(XXBAllowedCodingPropertyNames)allowedCodingPropertyNames;

/**
 *  这个数组中的属性名才会进行字典和模型的转换
 */
+ (NSMutableArray *)XXB_totalAllowedCodingPropertyNames;

#pragma mark - 归档属性黑名单配置
/**
 *  这个数组中的属性名将会被忽略：不进行归档
 *
 *  @param ignoredCodingPropertyNames          这个数组中的属性名将会被忽略：不进行归档
 */
+ (void)XXB_setupIgnoredCodingPropertyNames:(XXBIgnoredCodingPropertyNames)ignoredCodingPropertyNames;

/**
 *  这个数组中的属性名将会被忽略：不进行归档
 */
+ (NSMutableArray *)XXB_totalIgnoredCodingPropertyNames;

#pragma mark - 内部使用
+ (void)XXB_setupBlockReturnValue:(id (^)())block key:(const char *)key;

@end
