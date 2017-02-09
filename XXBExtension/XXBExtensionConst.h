//
//  XXBExtensionConst.h
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/9.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#ifndef __XXBExtensionConst__H__
#define __XXBExtensionConst__H__

#import <Foundation/Foundation.h>


// 过期
#define XXBExtensionDeprecated(dep) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, dep)

// 构建错误
#define XXBExtensionBuildError(clazz, msg) \
NSError *error = [NSError errorWithDomain:msg code:2500 userInfo:nil]; \
[clazz setXXB_error:error];


/**
 * 断言
 * @param condition   条件
 * @param returnValue 返回值
 */
#define XXBExtensionAssertError(condition, returnValue, clazz, msg) \
[clazz setXXB_error:nil]; \
if ((condition) == NO) { \
XXBExtensionBuildError(clazz, msg); \
return returnValue;\
}

#define XXBExtensionAssert2(condition, returnValue) \
if ((condition) == NO) return returnValue;

/**
 * 断言
 * @param condition   条件
 */
#define XXBExtensionAssert(condition) XXBExtensionAssert2(condition, )

/**
 * 断言
 * @param param         参数
 * @param returnValue   返回值
 */
#define XXBExtensionAssertParamNotNil2(param, returnValue) \
XXBExtensionAssert2((param) != nil, returnValue)

/**
 * 断言
 * @param param   参数
 */
#define XXBExtensionAssertParamNotNil(param) XXBExtensionAssertParamNotNil2(param, )

/**
 *  类型（属性类型）
 */
extern NSString *const XXBPropertyTypeInt;
extern NSString *const XXBPropertyTypeShort;
extern NSString *const XXBPropertyTypeFloat;
extern NSString *const XXBPropertyTypeDouble;
extern NSString *const XXBPropertyTypeLong;
extern NSString *const XXBPropertyTypeLongLong;
extern NSString *const XXBPropertyTypeChar;
extern NSString *const XXBPropertyTypeBOOL1;
extern NSString *const XXBPropertyTypeBOOL2;
extern NSString *const XXBPropertyTypePointer;

extern NSString *const XXBPropertyTypeIvar;
extern NSString *const XXBPropertyTypeMethod;
extern NSString *const XXBPropertyTypeBlock;
extern NSString *const XXBPropertyTypeClass;
extern NSString *const XXBPropertyTypeSEL;
extern NSString *const XXBPropertyTypeId;
#endif


