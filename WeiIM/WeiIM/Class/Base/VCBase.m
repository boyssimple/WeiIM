//
//  VCBase.m
//  WeiIM
//
//  Created by zhouMR on 2017/4/25.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "VCBase.h"

@interface VCBase ()

@end

@implementation VCBase

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"__%@__",[[self class] className]);
    self.view.backgroundColor = [UIColor whiteColor];
}

@end
