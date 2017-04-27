//
//  CellUserImg.m
//  LifeChat
//
//  Created by zhouMR on 16/5/9.
//  Copyright © 2016年 com.sean. All rights reserved.
//

#import "CellUserImg.h"

@implementation CellUserImg

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        
        self.ivImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.ivImg.layer.cornerRadius = 5;
        self.ivImg.layer.masksToBounds = TRUE;
        [self.contentView addSubview:self.ivImg];
        
        self.lbName = [[UILabel alloc]initWithFrame:CGRectZero];
        self.lbName.font = [UIFont systemFontOfSize:15*RATIO_WIDHT320];
        self.lbName.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.lbName];
    }
    return self;
}

- (void)layoutSubviews{
    CGRect r= self.ivImg.frame;
    r.size.width = 50*RATIO_WIDHT320;
    r.size.height = r.size.width;
    r.origin.x = 10;
    r.origin.y = (self.height-r.size.height)/2.0;
    self.ivImg.frame = r;
    
    r= self.lbName.frame;
    r.size.width = DEVICE_WIDTH-self.ivImg.right-20;
    r.size.height = 15*RATIO_WIDHT320;
    r.origin.x = self.ivImg.right+10;
    r.origin.y = (self.height - r.size.height)/2.0;
    self.lbName.frame = r;
}

-(void)updateData:(XMPPJID*)userId{
    __weak __typeof (self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *photoData = [[XmppCenter shareInstance] getImageData:userId.user];
        UIImage *headImg;
        if (photoData) {
            headImg = [UIImage imageWithData:photoData];
        }else{
            headImg = IMAGE(@"DefaultProfileHead");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.ivImg.image = headImg;
        });
    });
    
    self.lbName.text = userId.user;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
