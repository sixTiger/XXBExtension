//
//  XXBExtensionConst.m
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/9.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//
#ifndef __XXBExtensionConst__M__
#define __XXBExtensionConst__M__

#import <Foundation/Foundation.h>

/**
 *  成员变量类型（属性类型）
 */
NSString *const XXBPropertyTypeInt = @"i";
NSString *const XXBPropertyTypeShort = @"s";
NSString *const XXBPropertyTypeFloat = @"f";
NSString *const XXBPropertyTypeDouble = @"d";
NSString *const XXBPropertyTypeLong = @"l";
NSString *const XXBPropertyTypeLongLong = @"q";
NSString *const XXBPropertyTypeChar = @"c";
NSString *const XXBPropertyTypeBOOL1 = @"c";
NSString *const XXBPropertyTypeBOOL2 = @"b";
NSString *const XXBPropertyTypePointer = @"*";

NSString *const XXBPropertyTypeIvar = @"^{objc_ivar=}";
NSString *const XXBPropertyTypeMethod = @"^{objc_method=}";
NSString *const XXBPropertyTypeBlock = @"@?";
NSString *const XXBPropertyTypeClass = @"#";
NSString *const XXBPropertyTypeSEL = @":";
NSString *const XXBPropertyTypeId = @"@";

#endif
