//
//  XXBUser.h
//  XXBExtension
//
//  Created by 杨小兵 on 15/8/5.
//  Copyright (c) 2015年 杨小兵. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XXBUser;

@protocol XXBUserDelegate <NSObject>

- (void)callName:(XXBUser *)user andName:(NSString *)name;

@end

typedef enum {
    SexMale,
    SexFemale
} Sex;
@interface XXBUser : NSObject
@property(nonatomic ,weak) id                       deleagte;
/** 名称 */
@property (copy, nonatomic) NSString                *name;
/** 头像 */
@property (copy, nonatomic) NSString                *icon;
/** 年龄 */
@property (assign, nonatomic) unsigned int          age;
/** 身高 */
@property (copy, nonatomic) NSString                *height;
/** 财富 */
@property (strong, nonatomic) NSNumber              *money;
/** 性别 */
@property (assign, nonatomic) Sex                   sex;
/** 同性恋 */
@property (assign, nonatomic, getter=isGay) BOOL    gay;
@end
