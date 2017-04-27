//
//  FuncButton.m
//  WeiIM
//
//  Created by zhouMR on 2017/4/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "FuncButton.h"

@interface FuncButton()
@property (nonatomic, strong) UIView *vBg;
@property (nonatomic, strong) UIImageView *ivIcon;
@property (nonatomic, strong) UILabel *lbName;
@end
@implementation FuncButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        _vBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height - 25*RATIO_WIDHT320)];
        _vBg.layer.borderColor = RGB3(229).CGColor;
        _vBg.layer.borderWidth = 0.5;
        _vBg.backgroundColor = [UIColor whiteColor];
        _vBg.layer.cornerRadius = 10;
        _vBg.layer.masksToBounds = YES;
        [self addSubview:_vBg];
        
        CGFloat w = 30*RATIO_WIDHT320;
        _ivIcon = [[UIImageView alloc]initWithFrame:CGRectMake((_vBg.width-w)/2.0, (_vBg.height-w)/2.0, w, w)];
        [self addSubview:_ivIcon];
        
        _lbName = [[UILabel alloc]initWithFrame:CGRectMake(0, _vBg.bottom+5*RATIO_WIDHT320, self.width, 20*RATIO_WIDHT320)];
        _lbName.font = FONT(10*RATIO_WIDHT320);
        _lbName.textColor = [UIColor grayColor];
        _lbName.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_lbName];
    }
    return self;
}

- (void)updateData:(NSDictionary*)data{
    self.ivIcon.image = [UIImage imageNamed:[data objectForKey:@"icon"]];
    self.lbName.text = [data objectForKey:@"name"];
}

@end
