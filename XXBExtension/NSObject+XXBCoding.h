//
//  NSObject+XXBCoding.h
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/13.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 归档的实现
 */
#define XXBCodingImplementation \
- (id)initWithCoder:(NSCoder *)decoder \
{ \
if (self = [super init]) { \
[self XXB_decode:decoder]; \
} \
return self; \
} \
\
- (void)encodeWithCoder:(NSCoder *)encoder \
{ \
[self XXB_encode:encoder]; \
}

#define XXBExtensionCodingImplementation XXBCodingImplementation

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
@interface NSObject(XXBCoding)<XXBCoding>
/**
 *  解码（从文件中解析对象）
 */
- (void)XXB_decode:(NSCoder *)decoder;
/**
 *  编码（将对象写入文件中）
 */
- (void)XXB_encode:(NSCoder *)encoder;
@end
