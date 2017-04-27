//
//  FunctionView.h
//  WeiIM
//
//  Created by zhouMR on 2017/4/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FunctionViewDelegate;
@interface FunctionView : UIView
@property (nonatomic,weak)   id<FunctionViewDelegate> delegate;
@end

@protocol FunctionViewDelegate <NSObject>

- (void)functionView:(FunctionView *)functionView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
