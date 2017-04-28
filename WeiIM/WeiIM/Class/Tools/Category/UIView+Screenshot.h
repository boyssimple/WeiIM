//
//  UIView+Screenshot.h
//  WeiIM
//
//  Created by zhouMR on 2017/4/28.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Screenshot)
- (UIImage *)screenshot;
- (UIImage *)screenshotWithRect:(CGRect)rect;
@end
