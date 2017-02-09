//
//  NSObject+XXBKeyValue.m
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/9.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import "NSObject+XXBKeyValue.h"
#import "NSObject+XXBClass.h"

@implementation NSObject (XXBKeyValue)

#pragma mark - 错误
static const char XXBErrorKey = '\0';
+ (NSError *)mj_error
{
    return objc_getAssociatedObject(self, &XXBErrorKey);
}

+ (void)setMj_error:(NSError *)error
{
    objc_setAssociatedObject(self, &XXBErrorKey, error, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark - 模型 -> 字典时的参考
/** 模型转字典时，字典的key是否参考replacedKeyFromPropertyName等方法（父类设置了，子类也会继承下来） */
static const char XXBReferenceReplacedKeyWhenCreatingKeyValuesKey = '\0';
+ (void)XXB_referenceReplacedKeyWhenCreatingKeyValues:(BOOL)reference
{
    objc_setAssociatedObject(self, &XXBReferenceReplacedKeyWhenCreatingKeyValuesKey, @(reference), OBJC_ASSOCIATION_ASSIGN);
}

+ (BOOL)mj_isReferenceReplacedKeyWhenCreatingKeyValues
{
    __block id value = objc_getAssociatedObject(self, &XXBReferenceReplacedKeyWhenCreatingKeyValuesKey);
    if (!value) {
        [self XXB_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            value = objc_getAssociatedObject(c, &XXBReferenceReplacedKeyWhenCreatingKeyValuesKey);
            if (value) *stop = YES;
        }];
    }
    return [value boolValue];
}

@end
