//
//  FunctionView.m
//  WeiIM
//
//  Created by zhouMR on 2017/4/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "FunctionView.h"
#import "FuncButton.h"

@interface FunctionView()
@property (nonatomic, strong) UIView *vLine;
@property (nonatomic, strong) UIScrollView *contentView;
@end
@implementation FunctionView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _vLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
        _vLine.backgroundColor = RGB(218, 220, 220);
        [self addSubview:_vLine];
        _contentView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0.5, self.width, self.height-0.5)];
        _contentView.showsVerticalScrollIndicator = NO;
        [self addSubview:_contentView];
        
        CGFloat w= 50*RATIO_WIDHT320,h = 75*RATIO_WIDHT320;
        CGFloat x = (DEVICE_WIDTH - 4*w)/5.0;
        
        FuncButton *picBtn = [[FuncButton alloc]initWithFrame:CGRectMake(x, 15, w, h)];
        [picBtn updateData:@{@"name":@"图片",@"icon":@"Chat_Pic_Button"}];
        picBtn.tag = 1;
        [_contentView addSubview:picBtn];
        
        UITapGestureRecognizer *picTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(functionAction:)];
        [picBtn addGestureRecognizer:picTap];
        
        FuncButton *makePicBtn = [[FuncButton alloc]initWithFrame:CGRectMake(picBtn.right+x, 15, w, h)];
        [makePicBtn updateData:@{@"name":@"相机",@"icon":@"Chat_MakePic_Button"}];
        makePicBtn.tag = 2;
        [_contentView addSubview:makePicBtn];
        
        UITapGestureRecognizer *makePicTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(functionAction:)];
        [makePicBtn addGestureRecognizer:makePicTap];
        
        FuncButton *videoBtn = [[FuncButton alloc]initWithFrame:CGRectMake(makePicBtn.right+x, 15, w, h)];
        [videoBtn updateData:@{@"name":@"视频聊天",@"icon":@"Chat_Video_Button"}];
        videoBtn.tag = 3;
        [_contentView addSubview:videoBtn];
        
        UITapGestureRecognizer *videoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(functionAction:)];
        [videoBtn addGestureRecognizer:videoTap];
        
        FuncButton *locBtn = [[FuncButton alloc]initWithFrame:CGRectMake(videoBtn.right+x, 15, w, h)];
        [locBtn updateData:@{@"name":@"位置",@"icon":@"Chat_Loction_Button"}];
        locBtn.tag = 4;
        [_contentView addSubview:locBtn];
        
        UITapGestureRecognizer *locTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(functionAction:)];
        [locBtn addGestureRecognizer:locTap];
    }
    return self;
}

- (void)functionAction:(UIGestureRecognizer*)ges{
    NSInteger tag = ges.view.tag;
    if ([self.delegate respondsToSelector:@selector(functionView:clickedButtonAtIndex:)]) {
        [self.delegate functionView:self clickedButtonAtIndex:tag];
    }
}

@end
