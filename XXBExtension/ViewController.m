//
//  ViewController.m
//  XXBExtension
//
//  Created by 杨小兵 on 15/8/5.
//  Copyright (c) 2015年 杨小兵. All rights reserved.
//

#import "ViewController.h"
#import "XXBUser.h"

@interface ViewController ()

@end

@implementation ViewController
/**
 *  简单的字典 -> 模型
 */
void keyValues2object()
{
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"name" : @"Jack",
                           @"icon" : @"lufy.png",
                           @"age" : @"20",
                           @"height" : @1.55,
                           @"money" : @"100.9",
                           @"sex" : @(SexFemale),
                           //                           @"gay" : @"1"
                           //                           @"gay" : @"NO"
                           @"gay" : @"true"
                           };
    
    // 2.将字典转为User模型
    XXBUser *user = [XXBUser objectWithKeyValues:dict];
    
    // 3.打印User模型的属性
    NSLog(@"name=%@, icon=%@, age=%zd, height=%@, money=%@, sex=%d, gay=%d", user.name, user.icon, user.age, user.height, user.money, user.sex, user.gay);
}

@end
