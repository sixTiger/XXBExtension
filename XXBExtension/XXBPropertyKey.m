//
//  XXBPropertyKey.m
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/9.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import "XXBPropertyKey.h"

@implementation XXBPropertyKey

- (id)valueInObject:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]] && self.type == XXBPropertyKeyTypeDictionary) {
        return object[self.name];
    } else if ([object isKindOfClass:[NSArray class]] && self.type == XXBPropertyKeyTypeArray) {
        NSArray *array = object;
        NSUInteger index = self.name.intValue;
        if (index < array.count) return array[index];
        return nil;
    }
    return nil;
}
@end
