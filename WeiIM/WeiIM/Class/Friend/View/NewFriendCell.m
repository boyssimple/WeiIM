//
//  NewFriendCell.m
//  WeiIM
//
//  Created by zhouMR on 2017/4/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "NewFriendCell.h"
@interface NewFriendCell()
@property(nonatomic,strong)UIImageView *ivImg;
@property(nonatomic,strong)UILabel *lbName;
@property(nonatomic,strong)UILabel *lbMsg;
@property (nonatomic, strong) UIButton *status;
@end
@implementation NewFriendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _ivImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:_ivImg];
        
        _lbName = [[UILabel alloc]initWithFrame:CGRectZero];
        _lbName.font = FONT(12*RATIO_WIDHT320);
        [self.contentView addSubview:_lbName];
        
        _lbMsg = [[UILabel alloc]init];
        _lbMsg.textColor = RGB3(234);
        _lbMsg.font = [UIFont boldSystemFontOfSize:11*RATIO_WIDHT320];
        [self.contentView addSubview:_lbMsg];
        
        _status = [[UIButton alloc]init];
        [_status setTitleColor:RGB3(234) forState:UIControlStateNormal];
        _status.titleLabel.font = [UIFont boldSystemFontOfSize:11*RATIO_WIDHT320];
        [self.contentView addSubview:_status];
        
        _vLine = [[UIView alloc]initWithFrame:CGRectZero];
        _vLine.backgroundColor = GrayColor;
        [self.contentView addSubview:_vLine];
    }
    return self;
}

- (void)updateData:(NSInteger)type{
    [self.ivImg downloadImage:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1493783537&di=8c4388427fcb757bf6d8461ef683549d&imgtype=jpg&er=1&src=http%3A%2F%2F5.26923.com%2Fdownload%2Fpic%2F000%2F325%2F2b005fd2bbc9b998ec3d21387d5145ec.jpg"];
    self.lbName.text = @"该死的大佐";
    self.lbMsg.text = @"我是该死的大佐";
    
    if (type == 2) {
        [self.status setTitle:@"添加" forState:UIControlStateNormal];
        [self.status setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.status.backgroundColor = RGB3(247);
        self.status.layer.cornerRadius = 2;
        self.status.layer.masksToBounds = YES;
        self.status.layer.borderColor = RGB3(234).CGColor;
        self.status.layer.borderWidth = 0.5;
    }else{
        [self.status setTitle:@"已添加" forState:UIControlStateNormal];
        [self.status setTitleColor:RGB3(234) forState:UIControlStateNormal];
        self.status.backgroundColor = [UIColor clearColor];
        self.status.layer.cornerRadius = 0;
        self.status.layer.masksToBounds = NO;
        self.status.layer.borderWidth = 0;
    }
    self.type = type;
}

- (void)layoutSubviews{
    CGRect r = self.ivImg.frame;
    r.size.width = 30*RATIO_WIDHT320;
    r.size.height = r.size.width;
    r.origin.x = 10;
    r.origin.y = (self.height - r.size.height)/2.0;
    self.ivImg.frame = r;
    
    CGSize size = [self.lbName sizeThatFits:CGSizeMake(MAXFLOAT, 12*RATIO_WIDHT320)];
    r = self.lbName.frame;
    r.size.width = size.width;
    r.size.height = size.height;
    r.origin.x = self.ivImg.right + 10;
    r.origin.y = self.ivImg.y;
    self.lbName.frame = r;
    
    size = [self.lbMsg sizeThatFits:CGSizeMake(MAXFLOAT, 11*RATIO_WIDHT320)];
    r = self.lbMsg.frame;
    r.size.width = size.width;
    r.size.height = size.height;
    r.origin.x = self.lbName.x;
    r.origin.y = self.ivImg.bottom - r.size.height;
    self.lbMsg.frame = r;
    
    size = [self.status sizeThatFits:CGSizeMake(MAXFLOAT, 11*RATIO_WIDHT320)];
    if (self.type == 2) {
        size.width += 15;
        size.height -= 6;
    }
    r = self.status.frame;
    r.origin.x = self.width - 15-size.width;
    r.origin.y = (self.height-size.height)/2.0;
    r.size.width = size.width;
    r.size.height = size.height;
    self.status.frame = r;
    
    r = self.vLine.frame;
    r.size.width = DEVICE_WIDTH-10;
    r.size.height = 0.5;
    r.origin.x = 10;
    r.origin.y = self.height - r.size.height;
    self.vLine.frame = r;
}

+ (CGFloat)calHeight{
    return 40*RATIO_WIDHT320;
}

@end
