//
//  NSObject+XXBKeyValue.h
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/9.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXBProperty.h"

/**
 *  KeyValue协议
 */
@protocol XXBKeyValue <NSObject>
@optional
/**
 *  只有这个数组中的属性名才允许进行字典和模型的转换 默认是包含全部属性
 */
+ (NSArray *)XXB_allowedPropertyNames;

/**
 *  这个数组中的属性名将会被忽略：不进行字典和模型的转换
 */
+ (NSArray *)XXB_ignoredPropertyNames;

/**
 *  将属性名换为其他key去字典中取值
 *
 *  @return 字典中的key是属性名，value是从字典中取值用的key
 */
+ (NSDictionary *)XXB_replacedKeyFromPropertyName;

/**
 *  将属性名换为其他key去字典中取值
 *
 *  @return 从字典中取值用的key
 */
+ (id)XXB_replacedKeyFromPropertyName121:(NSString *)propertyName;

/**
 *  数组中需要转换的模型类
 *
 *  @return 字典中的key是数组属性名，value是数组中存放模型的Class（Class类型或者NSString类型）
 */
+ (NSDictionary *)XXB_objectClassInArray;

/**
 *  旧值换新值，用于过滤字典中的值
 *
 *  @param oldValue 旧值
 *
 *  @return 新值
 */
- (id)XXB_newValueFromOldValue:(id)oldValue property:(XXBProperty *)property;

/**
 *  当字典转模型完毕时调用
 */
- (void)XXB_keyValuesDidFinishConvertingToObject;

/**
 *  当模型转字典完毕时调用
 */
- (void)XXB_objectDidFinishConvertingToKeyValues;
@end


@interface NSObject (XXBKeyValue)<XXBKeyValue>


#pragma mark - 类方法
/**
 * 字典转模型过程中遇到的错误
 */
+ (NSError *)mj_error;

/**
 *  模型转字典时，字典的key是否参考replacedKeyFromPropertyName等方法（父类设置了，子类也会继承下来）
 */
+ (void)XXB_referenceReplacedKeyWhenCreatingKeyValues:(BOOL)reference;

@end
