//
//  FriendCell.m
//  WeiIM
//
//  Created by simple on 17/4/25.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "FriendCell.h"

@interface FriendCell()
@property(nonatomic,strong)UIImageView *ivImg;
@property(nonatomic,strong)UILabel *lbName;
@property(nonatomic,strong)UIView *vLine;
@end


@implementation FriendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _ivImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        _ivImg.backgroundColor = RGB3(234);
        [self.contentView addSubview:_ivImg];
        
        _lbName = [[UILabel alloc]initWithFrame:CGRectZero];
        _lbName.font = FONT(FONTSIZE);
        [self.contentView addSubview:_lbName];
        
        _vLine = [[UIView alloc]initWithFrame:CGRectZero];
        _vLine.backgroundColor = GrayColor;
        [self.contentView addSubview:_vLine];
    }
    return self;
}

- (void)updateData{
    [self.ivImg downloadImage:@"http://image.tianjimedia.com/uploadImages/2015/204/22/YMG9CAUWUM15.jpg" placeholder:@""];
    self.lbName.text = @"找幸福给你";
}

- (void)layoutSubviews{
    CGRect r = self.ivImg.frame;
    r.size.width = 30*RATIO_WIDHT320;
    r.size.height = r.size.width;
    r.origin.x = 10;
    r.origin.y = (self.height - r.size.height)/2.0;
    self.ivImg.frame = r;
    
    CGSize size = [self.lbName sizeThatFits:CGSizeMake(MAXFLOAT, FONTSIZE)];
    r = self.lbName.frame;
    r.size.width = size.width;
    r.size.height = size.height;
    r.origin.x = self.ivImg.right + 10;
    r.origin.y = (self.height - r.size.height)/2.0;
    self.lbName.frame = r;
    
    r = self.vLine.frame;
    r.size.width = DEVICE_WIDTH-10;
    r.size.height = 0.5;
    r.origin.x = 10;
    r.origin.y = self.height - r.size.height;
    self.vLine.frame = r;
}

@end
