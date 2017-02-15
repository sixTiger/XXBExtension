//
//  NSObject+XXBProperty.h
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/15.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXBProperty.h"

/**
 *  遍历成员变量用的block
 *
 *  @param property 成员的包装对象
 *  @param stop   YES代表停止遍历，NO代表继续遍历
 */
typedef void (^XXBPropertiesEnumeration)(XXBProperty *property, BOOL *stop);

/** 将属性名换为其他key去字典中取值 */

typedef NSDictionary * (^XXBReplacedKeyFromPropertyName)();

typedef id (^XXBReplacedKeyFromPropertyName121)(NSString *propertyName);

/** 数组中需要转换的模型类 */
typedef NSDictionary * (^XXBObjectClassInArray)();

/** 用于过滤字典中的值 */
typedef id (^XXBNewValueFromOldValue)(id object, id oldValue, XXBProperty *property);

@interface NSObject (XXBProperty)

#pragma mark - 遍历
/**
 *  遍历所有的成员
 */
+ (void)XXB_enumerateProperties:(XXBPropertiesEnumeration)enumeration;

#pragma mark - 新值配置
/**
 *  用于过滤字典中的值
 *
 *  @param newValueFormOldValue 用于过滤字典中的值
 */
+ (void)XXB_setupNewValueFromOldValue:(XXBNewValueFromOldValue)newValueFormOldValue;
+ (id)XXB_getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(__unsafe_unretained XXBProperty *)property;

#pragma mark - key配置
/**
 *  将属性名换为其他key去字典中取值
 *
 *  @param replacedKeyFromPropertyName 将属性名换为其他key去字典中取值
 */
+ (void)XXB_setupReplacedKeyFromPropertyName:(XXBReplacedKeyFromPropertyName)replacedKeyFromPropertyName;
/**
 *  将属性名换为其他key去字典中取值
 *
 *  @param replacedKeyFromPropertyName121 将属性名换为其他key去字典中取值
 */
+ (void)XXB_setupReplacedKeyFromPropertyName121:(XXBReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121;

#pragma mark - array model class配置
/**
 *  数组中需要转换的模型类
 *
 *  @param objectClassInArray          数组中需要转换的模型类
 */
+ (void)XXB_setupObjectClassInArray:(XXBObjectClassInArray)objectClassInArray;

@end
