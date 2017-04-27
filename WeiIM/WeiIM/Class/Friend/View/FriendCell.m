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
@property (nonatomic, strong) UILabel *status;
@property(nonatomic,strong)UIView *vLine;
@end


@implementation FriendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _ivImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:_ivImg];
        
        _lbName = [[UILabel alloc]initWithFrame:CGRectZero];
        _lbName.font = FONT(FONTSIZE*RATIO_WIDHT320);
        [self.contentView addSubview:_lbName];
        
        _status = [[UILabel alloc]init];
        _status.textColor = [UIColor blackColor];
        _status.font = [UIFont boldSystemFontOfSize:12*RATIO_WIDHT320];
        _status.hidden = YES;
        [self.contentView addSubview:_status];
        
        _vLine = [[UIView alloc]initWithFrame:CGRectZero];
        _vLine.backgroundColor = GrayColor;
        [self.contentView addSubview:_vLine];
    }
    return self;
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.ivImg.backgroundColor = [UIColor whiteColor];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.ivImg.backgroundColor = [UIColor whiteColor];
}


- (void)updateDataElse:(NSDictionary*)data{
    self.status.hidden = YES;
    self.ivImg.image = [UIImage imageNamed:[data objectForKey:@"img"]];
    self.lbName.text = [data objectForKey:@"name"];
}

- (void)updateData{
    self.ivImg.image = [UIImage imageNamed:@"GroupChat"];
    self.status.hidden = YES;
    self.lbName.text = @"群聊";
}

- (void)updateData:(XMPPUserMemoryStorageObject*)data{
    self.status.hidden = YES;
    NSString *user = data.jid.user;
    self.lbName.text = user;
    if (data.isOnline) {
        self.status.text = @"[在线]";
    }else{
        self.status.text = @"[离线]";
    }
    
    __weak __typeof (self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *photoData = [[XmppCenter shareInstance] getImageData:user];
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

- (void)layoutSubviews{
    CGRect r = self.ivImg.frame;
    r.size.width = 40*RATIO_WIDHT320;
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
    
    size = [self.status sizeThatFits:CGSizeMake(MAXFLOAT, 12*RATIO_WIDHT320)];
    r = self.status.frame;
    r.origin.x = self.width - 15-size.width;
    r.origin.y = (self.height-12*RATIO_WIDHT320)/2.0;
    r.size.width = size.width;
    r.size.height = 12*RATIO_WIDHT320;
    self.status.frame = r;
    
    r = self.vLine.frame;
    r.size.width = DEVICE_WIDTH-10;
    r.size.height = 0.5;
    r.origin.x = 10;
    r.origin.y = self.height - r.size.height;
    self.vLine.frame = r;
}

@end
