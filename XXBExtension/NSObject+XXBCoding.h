//
//  NSObject+XXBCoding.h
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/13.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XXBCoding <NSObject>
@optional
/**
 *  这个数组中的属性名才会进行归档
 */
+ (NSArray *)XXB_allowedCodingPropertyNames;
/**
 *  这个数组中的属性名将会被忽略：不进行归档
 */
+ (NSArray *)XXB_ignoredCodingPropertyNames;

@end
@interface NSObject(XXBCoding)

@end
