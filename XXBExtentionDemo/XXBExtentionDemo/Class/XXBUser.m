//
//  XXBUser.m
//  XXBExtension
//
//  Created by 杨小兵 on 15/8/5.
//  Copyright (c) 2015年 杨小兵. All rights reserved.
//

#import "XXBUser.h"

@interface XXBUser ()
@property(nonatomic ,strong) NSTimer *timer;
@end

@implementation XXBUser

- (instancetype)init {
    if (self = [super init]) {
//        [self performSelector:@selector(callDelegate) withObject:nil afterDelay:3.0];
        [self startTimer];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"User %s",__func__);
}

- (void)startTimer {
    _timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(callDelegate) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void)callDelegate {
    if ([self.deleagte respondsToSelector:@selector(callName:andName:)]) {
        [self.deleagte callName:self andName:@"It is a Name"];
    }
}
@end
