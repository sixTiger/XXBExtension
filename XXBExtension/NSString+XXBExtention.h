//
//  NSString+XXBExtention.h
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/15.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XXBExtention)

/**
 *  驼峰转下划线（loveYou -> love_you）
 */
- (NSString *)XXB_underlineFromCamel;
/**
 *  下划线转驼峰（love_you -> loveYou）
 */
- (NSString *)XXB_camelFromUnderline;
/**
 * 首字母变大写
 */
- (NSString *)XXB_firstCharUpper;
/**
 * 首字母变小写
 */
- (NSString *)XXB_firstCharLower;

- (BOOL)XXB_isPureInt;

- (NSURL *)XXB_url;
@end
