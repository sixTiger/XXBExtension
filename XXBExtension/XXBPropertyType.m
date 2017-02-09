//
//  XXBPropertyType.m
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/9.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import "XXBPropertyType.h"
#import "XXBExtensionConst.h"
#import "XXBFoundation.h"

@implementation XXBPropertyType
static NSMutableDictionary *types_;
+ (void)initialize
{
    types_ = [NSMutableDictionary dictionary];
}

+ (instancetype)cachedTypeWithCode:(NSString *)code
{
    XXBExtensionAssertParamNotNil2(code, nil);
    @synchronized (self) {
        XXBPropertyType *type = types_[code];
        if (type == nil) {
            type = [[self alloc] init];
            type.code = code;
            types_[code] = type;
        }
        return type;
    }
}

#pragma mark - 公共方法
- (void)setCode:(NSString *)code
{
    _code = code;
    
    XXBExtensionAssertParamNotNil(code);
    
    if ([code isEqualToString:XXBPropertyTypeId]) {
        _idType = YES;
    } else if (code.length == 0) {
        _KVCDisabled = YES;
    } else if (code.length > 3 && [code hasPrefix:@"@\""]) {
        // 去掉@"和"，截取中间的类型名称
        _code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _typeClass = NSClassFromString(_code);
        _fromFoundation = [XXBFoundation isClassFromFoundation:_typeClass];
        _numberType = [_typeClass isSubclassOfClass:[NSNumber class]];
    } else if ([code isEqualToString:XXBPropertyTypeSEL] ||
               [code isEqualToString:XXBPropertyTypeIvar] ||
               [code isEqualToString:XXBPropertyTypeMethod]) {
        _KVCDisabled = YES;
    }
    
    // 是否为数字类型
    NSString *lowerCode = _code.lowercaseString;
    NSArray *numberTypes = @[XXBPropertyTypeInt, XXBPropertyTypeShort, XXBPropertyTypeBOOL1, XXBPropertyTypeBOOL2, XXBPropertyTypeFloat, XXBPropertyTypeDouble, XXBPropertyTypeLong, XXBPropertyTypeLongLong, XXBPropertyTypeChar];
    if ([numberTypes containsObject:lowerCode]) {
        _numberType = YES;
        
        if ([lowerCode isEqualToString:XXBPropertyTypeBOOL1]
            || [lowerCode isEqualToString:XXBPropertyTypeBOOL2]) {
            _boolType = YES;
        }
    }
}

@end
