//
//  NSObject+XXBKeyValue.m
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/9.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import "NSObject+XXBKeyValue.h"
#import "NSObject+XXBClass.h"
#import "NSObject+XXBProperty.h"
#import "XXBExtensionConst.h"
#import "NSString+XXBExtention.h"
#import "XXBFoundation.h"

@implementation NSObject (XXBKeyValue)

#pragma mark - 错误
static const char XXBErrorKey = '\0';
+ (NSError *)XXB_error
{
    return objc_getAssociatedObject(self, &XXBErrorKey);
}

+ (void)setXXB_error:(NSError *)error
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

+ (BOOL)XXB_isReferenceReplacedKeyWhenCreatingKeyValues
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

#pragma mark - --常用的对象--
static NSNumberFormatter *XXBNumberFormatter_;
+ (void)load
{
    XXBNumberFormatter_ = [[NSNumberFormatter alloc] init];
    
    // 默认设置
    [self XXB_referenceReplacedKeyWhenCreatingKeyValues:YES];
}

#pragma mark - --公共方法--
#pragma mark - 字典 -> 模型

- (instancetype)XXB_setKeyValues:(id)keyValues
{
    return [self XXB_setKeyValues:keyValues context:nil];
}

/**
 核心代码：
 */
- (instancetype)XXB_setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context
{
    keyValues = [keyValues XXB_keyValues];
    XXBExtensionAssertError([keyValues isKindOfClass:[NSDictionary class]], self, [self class], @"keyValues参数不是一个字典");
    Class clazz = [self class];
    NSArray *allowedPropertyNames = [clazz XXB_totalAllowedPropertyNames];
    NSArray *ignoredPropertyNames = [clazz XXB_totalIgnoredPropertyNames];
    //通过封装的方法回调一个通过运行时编写的，用于返回属性列表的方法。
    [clazz XXB_enumerateProperties:^(XXBProperty *property, BOOL *stop) {
        @try {
            // 0.检测是否被忽略
            if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
            if ([ignoredPropertyNames containsObject:property.name]) return;
            
            // 1.取出属性值
            id value;
            NSArray *propertyKeyses = [property propertyKeysForClass:clazz];
            for (NSArray *propertyKeys in propertyKeyses) {
                value = keyValues;
                for (XXBPropertyKey *propertyKey in propertyKeys) {
                    value = [propertyKey valueInObject:value];
                }
                if (value) break;
            }
            
            // 值的过滤
            id newValue = [clazz XXB_getNewValueFromObject:self oldValue:value property:property];
            if (newValue != value) { // 有过滤后的新值
                // Default 数据 如果有默认数据的话是不需要解析的
                [property setValue:newValue forObject:self];
                return;
            }
            
            // 如果没有值，就直接返回
            if (!value || value == [NSNull null]) return;
            
            
            
            // 2.复杂处理
            XXBPropertyType *type = property.type;
            Class propertyClass = type.typeClass;
            Class objectClass = [property objectClassInArrayForClass:[self class]];
            
            // 不可变 -> 可变处理
            if (propertyClass == [NSMutableArray class] && [value isKindOfClass:[NSArray class]]) {
                value = [NSMutableArray arrayWithArray:value];
            } else if (propertyClass == [NSMutableDictionary class] && [value isKindOfClass:[NSDictionary class]]) {
                value = [NSMutableDictionary dictionaryWithDictionary:value];
            } else if (propertyClass == [NSMutableString class] && [value isKindOfClass:[NSString class]]) {
                value = [NSMutableString stringWithString:value];
            } else if (propertyClass == [NSMutableData class] && [value isKindOfClass:[NSData class]]) {
                value = [NSMutableData dataWithData:value];
            }
            
            if (!type.isFromFoundation && propertyClass) {
                // 模型属性 字典转模型
                value = [propertyClass XXB_objectWithKeyValues:value context:context];
            } else if (objectClass) {
                if (objectClass == [NSURL class] && [value isKindOfClass:[NSArray class]]) {
                    // string array -> url array
                    NSMutableArray *urlArray = [NSMutableArray array];
                    for (NSString *string in value) {
                        if (![string isKindOfClass:[NSString class]]) continue;
                        [urlArray addObject:[string XXB_url]];
                    }
                    value = urlArray;
                } else {
                    // 字典数组-->模型数组 数组转模型
                    value = [objectClass XXB_objectArrayWithKeyValuesArray:value context:context];
                }
            } else {
                //属性赋值 属性直接赋值
                if (propertyClass == [NSString class]) {
                    if ([value isKindOfClass:[NSNumber class]]) {
                        // NSNumber -> NSString
                        value = [value description];
                    } else if ([value isKindOfClass:[NSURL class]]) {
                        // NSURL -> NSString
                        value = [value absoluteString];
                    }
                } else if ([value isKindOfClass:[NSString class]]) {
                    if (propertyClass == [NSURL class]) {
                        // NSString -> NSURL
                        // 字符串转码
                        value = [value XXB_url];
                    } else if (type.isNumberType) {
                        NSString *oldValue = value;
                        
                        // NSString -> NSNumber
                        if (type.typeClass == [NSDecimalNumber class]) {
                            value = [NSDecimalNumber decimalNumberWithString:oldValue];
                        } else {
                            value = [XXBNumberFormatter_ numberFromString:oldValue];
                        }
                        
                        // 如果是BOOL
                        if (type.isBoolType) {
                            // 字符串转BOOL（字符串没有charValue方法）
                            // 系统会调用字符串的charValue转为BOOL类型
                            NSString *lower = [oldValue lowercaseString];
                            if ([lower isEqualToString:@"yes"] || [lower isEqualToString:@"true"]) {
                                value = @YES;
                            } else if ([lower isEqualToString:@"no"] || [lower isEqualToString:@"false"]) {
                                value = @NO;
                            }
                        }
                    }
                }
                // value和property类型不匹配
                if (propertyClass && ![value isKindOfClass:propertyClass]) {
                    value = nil;
                }
            }
            
            // 3.赋值
            [property setValue:value forObject:self];
            
            
            
        } @catch (NSException *exception) {
            XXBExtensionBuildError([self class], exception.reason);
            XXBExtensionLog(@"%@", exception);
        } @finally {
        }
    }];
    
    // 转换完成
    
    if([self respondsToSelector:@selector(XXB_keyValuesDidFinishConvertingToObject)]) {
        [self XXB_keyValuesDidFinishConvertingToObject];
    }
    
    return self;
}

+ (instancetype)XXB_objectWithKeyValues:(id)keyValues {
    
    return [self XXB_objectWithKeyValues:keyValues context:nil];
}

+ (instancetype)XXB_objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context {
    // 获得JSON对象
    keyValues = [keyValues XXB_JSONObject];
    XXBExtensionAssertError([keyValues isKindOfClass:[NSDictionary class]], nil, [self class], @"keyValues参数不是一个字典");
    
    if ([self isSubclassOfClass:[NSManagedObject class]] && context) {
        NSString *entityName = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
        return [[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context] XXB_setKeyValues:keyValues context:context];
    }
    return [[[self alloc] init] XXB_setKeyValues:keyValues];
}

+ (instancetype)XXB_objectWithFilename:(NSString *)filename {
    XXBExtensionAssertError(filename != nil, nil, [self class], @"filename参数为nil");
    
    return [self XXB_objectWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil]];
}

+ (instancetype)XXB_objectWithFile:(NSString *)file {
    XXBExtensionAssertError(file != nil, nil, [self class], @"file参数为nil");
    
    return [self XXB_objectWithKeyValues:[NSDictionary dictionaryWithContentsOfFile:file]];
}


#pragma mark - 字典数组 -> 模型数组
+ (NSMutableArray *)XXB_objectArrayWithKeyValuesArray:(NSArray *)keyValuesArray {
    return [self XXB_objectArrayWithKeyValuesArray:keyValuesArray context:nil];
}

+ (NSMutableArray *)XXB_objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context {
    // 如果是JSON字符串
    keyValuesArray = [keyValuesArray XXB_JSONObject];
    
    // 1.判断真实性
    XXBExtensionAssertError([keyValuesArray isKindOfClass:[NSArray class]], nil, [self class], @"keyValuesArray参数不是一个数组");
    
    // 如果数组里面放的是NSString、NSNumber等数据
    if ([XXBFoundation isClassFromFoundation:self]) return [NSMutableArray arrayWithArray:keyValuesArray];
    
    // 2.创建数组
    NSMutableArray *modelArray = [NSMutableArray array];
    
    // 3.遍历
    for (NSDictionary *keyValues in keyValuesArray) {
        if ([keyValues isKindOfClass:[NSArray class]]){
            [modelArray addObject:[self XXB_objectArrayWithKeyValuesArray:keyValues context:context]];
        } else {
            id model = [self XXB_objectWithKeyValues:keyValues context:context];
            if (model) [modelArray addObject:model];
        }
    }
    
    return modelArray;
}

+ (NSMutableArray *)XXB_objectArrayWithFilename:(NSString *)filename {
    XXBExtensionAssertError(filename != nil, nil, [self class], @"filename参数为nil");
    return [self XXB_objectArrayWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil]];
}

+ (NSMutableArray *)XXB_objectArrayWithFile:(NSString *)file {
    XXBExtensionAssertError(file != nil, nil, [self class], @"file参数为nil");
    
    return [self XXB_objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:file]];
}

#pragma mark - 模型 -> 字典
- (NSMutableDictionary *)XXB_keyValues {
    return [self XXB_keyValuesWithKeys:nil ignoredKeys:nil];
}

- (NSMutableDictionary *)XXB_keyValuesWithKeys:(NSArray *)keys {
    return [self XXB_keyValuesWithKeys:keys ignoredKeys:nil];
}

- (NSMutableDictionary *)XXB_keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys {
    return [self XXB_keyValuesWithKeys:nil ignoredKeys:ignoredKeys];
}

- (NSMutableDictionary *)XXB_keyValuesWithKeys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys {
    // 如果自己不是模型类, 那就返回自己
    XXBExtensionAssertError(![XXBFoundation isClassFromFoundation:[self class]], (NSMutableDictionary *)self, [self class], @"不是自定义的模型类")
    
    id keyValues = [NSMutableDictionary dictionary];
    
    Class clazz = [self class];
    NSArray *allowedPropertyNames = [clazz XXB_totalAllowedPropertyNames];
    NSArray *ignoredPropertyNames = [clazz XXB_totalIgnoredPropertyNames];
    
    [clazz XXB_enumerateProperties:^(XXBProperty *property, BOOL *stop) {
        @try {
            // 0.检测是否被忽略
            if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
            if ([ignoredPropertyNames containsObject:property.name]) return;
            if (keys.count && ![keys containsObject:property.name]) return;
            if ([ignoredKeys containsObject:property.name]) return;
            
            // 1.取出属性值
            id value = [property valueForObject:self];
            if (!value) return;
            
            // 2.如果是模型属性
            XXBPropertyType *type = property.type;
            Class propertyClass = type.typeClass;
            if (!type.isFromFoundation && propertyClass) {
                value = [value XXB_keyValues];
            } else if ([value isKindOfClass:[NSArray class]]) {
                // 3.处理数组里面有模型的情况
                value = [NSObject XXB_keyValuesArrayWithObjectArray:value];
            } else if (propertyClass == [NSURL class]) {
                value = [value absoluteString];
            }
            
            // 4.赋值
            if ([clazz XXB_isReferenceReplacedKeyWhenCreatingKeyValues]) {
                NSArray *propertyKeys = [[property propertyKeysForClass:clazz] firstObject];
                NSUInteger keyCount = propertyKeys.count;
                // 创建字典
                __block id innerContainer = keyValues;
                [propertyKeys enumerateObjectsUsingBlock:^(XXBPropertyKey *propertyKey, NSUInteger idx, BOOL *stop) {
                    // 下一个属性
                    XXBPropertyKey *nextPropertyKey = nil;
                    if (idx != keyCount - 1) {
                        nextPropertyKey = propertyKeys[idx + 1];
                    }
                    
                    if (nextPropertyKey) { // 不是最后一个key
                        // 当前propertyKey对应的字典或者数组
                        id tempInnerContainer = [propertyKey valueInObject:innerContainer];
                        if (tempInnerContainer == nil || [tempInnerContainer isKindOfClass:[NSNull class]]) {
                            if (nextPropertyKey.type == XXBPropertyKeyTypeDictionary) {
                                tempInnerContainer = [NSMutableDictionary dictionary];
                            } else {
                                tempInnerContainer = [NSMutableArray array];
                            }
                            if (propertyKey.type == XXBPropertyKeyTypeDictionary) {
                                innerContainer[propertyKey.name] = tempInnerContainer;
                            } else {
                                innerContainer[propertyKey.name.intValue] = tempInnerContainer;
                            }
                        }
                        
                        if ([tempInnerContainer isKindOfClass:[NSMutableArray class]]) {
                            NSMutableArray *tempInnerContainerArray = tempInnerContainer;
                            int index = nextPropertyKey.name.intValue;
                            while (tempInnerContainerArray.count < index + 1) {
                                [tempInnerContainerArray addObject:[NSNull null]];
                            }
                        }
                        
                        innerContainer = tempInnerContainer;
                    } else { // 最后一个key
                        if (propertyKey.type == XXBPropertyKeyTypeDictionary) {
                            innerContainer[propertyKey.name] = value;
                        } else {
                            innerContainer[propertyKey.name.intValue] = value;
                        }
                    }
                }];
            } else {
                keyValues[property.name] = value;
            }
        } @catch (NSException *exception) {
            XXBExtensionBuildError([self class], exception.reason);
            XXBExtensionLog(@"%@", exception);
        }
    }];
    
    // 转换完毕
    if ([self respondsToSelector:@selector(XXB_objectDidFinishConvertingToKeyValues)]) {
        [self XXB_objectDidFinishConvertingToKeyValues];
    }
    
    return keyValues;
}

#pragma mark - 模型数组 -> 字典数组
+ (NSMutableArray *)XXB_keyValuesArrayWithObjectArray:(NSArray *)objectArray {
    return [self XXB_keyValuesArrayWithObjectArray:objectArray keys:nil ignoredKeys:nil];
}

+ (NSMutableArray *)XXB_keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys {
    return [self XXB_keyValuesArrayWithObjectArray:objectArray keys:keys ignoredKeys:nil];
}

+ (NSMutableArray *)XXB_keyValuesArrayWithObjectArray:(NSArray *)objectArray ignoredKeys:(NSArray *)ignoredKeys {
    return [self XXB_keyValuesArrayWithObjectArray:objectArray keys:nil ignoredKeys:ignoredKeys];
}

+ (NSMutableArray *)XXB_keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys {
    // 0.判断真实性
    XXBExtensionAssertError([objectArray isKindOfClass:[NSArray class]], nil, [self class], @"objectArray参数不是一个数组");
    
    // 1.创建数组
    NSMutableArray *keyValuesArray = [NSMutableArray array];
    for (id object in objectArray) {
        if (keys) {
            [keyValuesArray addObject:[object XXB_keyValuesWithKeys:keys]];
        } else {
            [keyValuesArray addObject:[object XXB_keyValuesWithIgnoredKeys:ignoredKeys]];
        }
    }
    return keyValuesArray;
}

#pragma mark - 转换为JSON
- (NSData *)XXB_JSONData {
    if ([self isKindOfClass:[NSString class]]) {
        return [((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([self isKindOfClass:[NSData class]]) {
        return (NSData *)self;
    }
    return [NSJSONSerialization dataWithJSONObject:[self XXB_JSONObject] options:kNilOptions error:nil];
}

- (id)XXB_JSONObject {
    if ([self isKindOfClass:[NSString class]]) {
        return [NSJSONSerialization JSONObjectWithData:[((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    } else if ([self isKindOfClass:[NSData class]]) {
        return [NSJSONSerialization JSONObjectWithData:(NSData *)self options:kNilOptions error:nil];
    }
    return self.XXB_keyValues;
}

- (NSString *)XXB_JSONString {
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    } else if ([self isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:(NSData *)self encoding:NSUTF8StringEncoding];
    }
    return [[NSString alloc] initWithData:[self XXB_JSONData] encoding:NSUTF8StringEncoding];
}

@end
