//
//  XXBPropertyKey.h
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/9.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    XXBPropertyKeyTypeDictionary = 0,       // 字典的key
    XXBPropertyKeyTypeArray                 // 数组的key
} XXBPropertyKeyType;

@interface XXBPropertyKey : NSObject

/** key的名字 */
@property (copy,   nonatomic) NSString *name;

/** key的种类，可能是@"10"，可能是@"age" */
@property (assign, nonatomic) XXBPropertyKeyType type;

/**
 *  根据当前的key，也就是name，从object（字典或者数组）中取值
 */
- (id)valueInObject:(id)object;
@end
