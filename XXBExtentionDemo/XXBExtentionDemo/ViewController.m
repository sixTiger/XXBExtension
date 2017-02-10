//
//  ViewController.m
//  XXBExtentionDemo
//
//  Created by baidu on 17/2/9.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import "ViewController.h"
#import "XXBUser.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSMutableArray *array = [NSMutableArray array];
    for (int  i = 0 ; i< 10 ; i++) {
        [array addObject:@(i)];
    }
    NSRange rang=NSMakeRange(0, 5);
    NSArray *newArray=[array subarrayWithRange:rang];
    [array removeObjectsInRange:rang];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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
    XXBUser *user;
    //    = [XXBUser objectWithKeyValues:dict];
    
    // 3.打印User模型的属性
    NSLog(@"name=%@, icon=%@, age=%zd, height=%@, money=%@, sex=%d, gay=%d", user.name, user.icon, user.age, user.height, user.money, user.sex, user.gay);
}

@end
