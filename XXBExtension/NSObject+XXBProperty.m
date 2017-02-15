//
//  NSObject+XXBProperty.m
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/15.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import "NSObject+XXBProperty.h"
#import <objc/runtime.h>
#import "XXBExtensionConst.h"
#import "NSObject+XXBKeyValue.h"
#import "NSObject+XXBClass.h"
#import "XXBFoundation.h"

static const char               XXBReplacedKeyFromPropertyNameKey = '\0';
static const char               XXBReplacedKeyFromPropertyName121Key = '\0';
static const char               XXBNewValueFromOldValueKey = '\0';
static const char               XXBObjectClassInArrayKey = '\0';
static const char               XXBCachedPropertiesKey = '\0';

static NSMutableDictionary      *XXBReplacedKeyFromPropertyNameDict_;
static NSMutableDictionary      *XXBReplacedKeyFromPropertyName121Dict_;
static NSMutableDictionary      *XXBNewValueFromOldValueDict_;
static NSMutableDictionary      *XXBObjectClassInArrayDict_;
static NSMutableDictionary      *XXBCachedPropertiesDict_;
@implementation NSObject(XXBProperty)

+ (void)load {
    XXBReplacedKeyFromPropertyNameDict_ = [NSMutableDictionary dictionary];
    XXBReplacedKeyFromPropertyName121Dict_ = [NSMutableDictionary dictionary];
    XXBNewValueFromOldValueDict_ = [NSMutableDictionary dictionary];
    XXBObjectClassInArrayDict_ = [NSMutableDictionary dictionary];
    XXBCachedPropertiesDict_ = [NSMutableDictionary dictionary];
}

+ (NSMutableDictionary *)dictForKey:(const void *)key {
    @synchronized (self) {
        if (key == &XXBReplacedKeyFromPropertyNameKey) return XXBReplacedKeyFromPropertyNameDict_;
        if (key == &XXBReplacedKeyFromPropertyName121Key) return XXBReplacedKeyFromPropertyName121Dict_;
        if (key == &XXBNewValueFromOldValueKey) return XXBNewValueFromOldValueDict_;
        if (key == &XXBObjectClassInArrayKey) return XXBObjectClassInArrayDict_;
        if (key == &XXBCachedPropertiesKey) return XXBCachedPropertiesDict_;
        return nil;
    }
}

#pragma mark - --私有方法--
+ (id)propertyKey:(NSString *)propertyName {
    XXBExtensionAssertParamNotNil2(propertyName, nil);
    
    __block id key = nil;
    // 查看有没有需要替换的key
    if ([self respondsToSelector:@selector(XXB_replacedKeyFromPropertyName121:)]) {
        key = [self XXB_replacedKeyFromPropertyName121:propertyName];
    }
    
    // 调用block
    if (!key) {
        [self XXB_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            XXBReplacedKeyFromPropertyName121 block = objc_getAssociatedObject(c, &XXBReplacedKeyFromPropertyName121Key);
            if (block) {
                key = block(propertyName);
            }
            if (key) *stop = YES;
        }];
    }
    
    // 查看有没有需要替换的key
    if ((!key || [key isEqual:propertyName]) && [self respondsToSelector:@selector(XXB_replacedKeyFromPropertyName)]) {
        key = [self XXB_replacedKeyFromPropertyName][propertyName];
    }
    
    if (!key || [key isEqual:propertyName]) {
        [self XXB_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSDictionary *dict = objc_getAssociatedObject(c, &XXBReplacedKeyFromPropertyNameKey);
            if (dict) {
                key = dict[propertyName];
            }
            if (key && ![key isEqual:propertyName]) *stop = YES;
        }];
    }
    // 2.用属性名作为key
    if (!key) key = propertyName;
    
    return key;
}

+ (Class)propertyObjectClassInArray:(NSString *)propertyName {
    __block id clazz = nil;
    if ([self respondsToSelector:@selector(XXB_objectClassInArray)]) {
        clazz = [self XXB_objectClassInArray][propertyName];
    }
    
    if (!clazz) {
        [self XXB_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSDictionary *dict = objc_getAssociatedObject(c, &XXBObjectClassInArrayKey);
            if (dict) {
                clazz = dict[propertyName];
            }
            if (clazz) *stop = YES;
        }];
    }
    // 如果是NSString类型
    if ([clazz isKindOfClass:[NSString class]]) {
        clazz = NSClassFromString(clazz);
    }
    return clazz;
}

#pragma mark - --公共方法--
+ (void)XXB_enumerateProperties:(XXBPropertiesEnumeration)enumeration {
    // 获得成员变量
    NSArray *cachedProperties = [self properties];
    
    // 遍历成员变量
    BOOL stop = NO;
    for (XXBProperty *property in cachedProperties) {
        enumeration(property, &stop);
        if (stop) break;
    }
}

#pragma mark - 公共方法
+ (NSMutableArray *)properties {
    NSMutableArray *cachedProperties = [self dictForKey:&XXBCachedPropertiesKey][NSStringFromClass(self)];
    
    if (cachedProperties == nil) {
        cachedProperties = [NSMutableArray array];
        
        [self XXB_enumerateClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            // 1.获得所有的成员变量
            unsigned int outCount = 0;
            objc_property_t *properties = class_copyPropertyList(c, &outCount);
            
            // 2.遍历每一个成员变量
            for (unsigned int i = 0; i<outCount; i++) {
                XXBProperty *property = [XXBProperty cachedPropertyWithProperty:properties[i]];
                // 过滤掉Foundation框架类里面的属性
                if ([XXBFoundation isClassFromFoundation:property.srcClass]) continue;
                property.srcClass = c;
                [property setOriginKey:[self propertyKey:property.name] forClass:self];
                [property setObjectClassInArray:[self propertyObjectClassInArray:property.name] forClass:self];
                [cachedProperties addObject:property];
            }
            
            // 3.释放内存
            free(properties);
        }];
        
        [self dictForKey:&XXBCachedPropertiesKey][NSStringFromClass(self)] = cachedProperties;
    }
    return cachedProperties;
}


#pragma mark - 新值配置
+ (void)XXB_setupNewValueFromOldValue:(XXBNewValueFromOldValue)newValueFormOldValue {
    objc_setAssociatedObject(self, &XXBNewValueFromOldValueKey, newValueFormOldValue, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (id)XXB_getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(XXBProperty *__unsafe_unretained)property {
    // 如果有实现方法
    if ([object respondsToSelector:@selector(XXB_newValueFromOldValue:property:)]) {
        return [object XXB_newValueFromOldValue:oldValue property:property];
    }
    
    // 查看静态设置
    __block id newValue = oldValue;
    [self XXB_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        XXBNewValueFromOldValue block = objc_getAssociatedObject(c, &XXBNewValueFromOldValueKey);
        if (block) {
            newValue = block(object, oldValue, property);
            *stop = YES;
        }
    }];
    return newValue;
}

#pragma mark - array model class配置
+ (void)XXB_setupObjectClassInArray:(XXBObjectClassInArray)objectClassInArray {
    [self XXB_setupBlockReturnValue:objectClassInArray key:&XXBObjectClassInArrayKey];
    [[self dictForKey:&XXBCachedPropertiesKey] removeAllObjects];
}

#pragma mark - key配置
+ (void)XXB_setupReplacedKeyFromPropertyName:(XXBReplacedKeyFromPropertyName)replacedKeyFromPropertyName {
    [self XXB_setupBlockReturnValue:replacedKeyFromPropertyName key:&XXBReplacedKeyFromPropertyNameKey];
    [[self dictForKey:&XXBCachedPropertiesKey] removeAllObjects];
}

+ (void)XXB_setupReplacedKeyFromPropertyName121:(XXBReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121 {
    objc_setAssociatedObject(self, &XXBReplacedKeyFromPropertyName121Key, replacedKeyFromPropertyName121, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [[self dictForKey:&XXBCachedPropertiesKey] removeAllObjects];
}

@end
