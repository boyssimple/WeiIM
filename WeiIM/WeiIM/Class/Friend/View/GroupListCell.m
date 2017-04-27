//
//  FriendCell.m
//  WeiIM
//
//  Created by simple on 17/4/25.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "GroupListCell.h"

@interface GroupListCell()
@property(nonatomic,strong)UIImageView *ivImg;
@property(nonatomic,strong)UILabel *lbName;
@end


@implementation GroupListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _ivImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:_ivImg];
        
        _lbName = [[UILabel alloc]initWithFrame:CGRectZero];
        _lbName.font = FONT(FONTSIZE*RATIO_WIDHT320);
        [self.contentView addSubview:_lbName];
        
        _vLine = [[UIView alloc]initWithFrame:CGRectZero];
        _vLine.backgroundColor = GrayColor;
        [self.contentView addSubview:_vLine];
    }
    return self;
}


- (void)updateData:(DDXMLElement*)data{
    self.ivImg.image = [UIImage imageNamed:@"GroupChat"];
    self.lbName.text = [data attributeForName:@"name"].stringValue;
}

/*
- (void)updateData:(XMPPUserMemoryStorageObject*)data{
    __weak __typeof (self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *photoData = [[XmppCenter shareInstance] getImageData:[XmppCenter shareInstance].myJid.user];
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
    
}
 */

- (void)layoutSubviews{
    CGRect r = self.ivImg.frame;
    r.size.width = 30*RATIO_WIDHT320;
    r.size.height = r.size.width;
    r.origin.x = 10;
    r.origin.y = (self.height - r.size.height)/2.0;
    self.ivImg.frame = r;
    
    CGSize size = [self.lbName sizeThatFits:CGSizeMake(MAXFLOAT, FONTSIZE*RATIO_WIDHT320)];
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
