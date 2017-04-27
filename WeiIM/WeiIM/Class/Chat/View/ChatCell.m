//
//  ChatCell.m
//  WeiIM
//
//  Created by zhouMR on 2017/4/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "ChatCell.h"
#define kMaxContainerWidth 220.f
#define MaxChatImageViewWidh 200.f
#define MaxChatImageViewHeight 300.f

@interface ChatCell()
@property (nonatomic,strong)  UIImageView *ivUserImg;
@property (nonatomic,strong)  UIView *container;
@property(nonatomic,strong)UIImageView *containerImageView;
@property(nonatomic,strong)UIImageView *maskViewImage;
@property (nonatomic, strong) UILabel *lbContent;   //文字消息
@property(nonatomic,strong)UIImageView *ivImg;      //图片消息
@end
@implementation ChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setBackgroundColor:[UIColor clearColor]];
    _ivUserImg = [[UIImageView alloc]init];
    [self.contentView addSubview:_ivUserImg];
    
    _container = [[UIView alloc]init];
    [self.contentView addSubview:_container];
    
    //消息背景
    _containerImageView = [[UIImageView alloc]init];
    [_container addSubview:_containerImageView];
    
    _maskViewImage = [[UIImageView alloc]init];
    
    //文字消息
    _lbContent = [UILabel new];
    _lbContent.font = FONT(14*RATIO_WIDHT320);
    _lbContent.numberOfLines = 0;
    [_container addSubview:_lbContent];
    
    //图片消息
    _ivImg = [[UIImageView alloc]init];
    _ivImg.hidden = YES;
    _ivImg.userInteractionEnabled = YES;
    [_container addSubview:_ivImg];
}

-(void)updateData:(XMPPMessageArchiving_Message_CoreDataObject *)msg{
    NSString *user = msg.bareJid.user;
    if (msg.isOutgoing) {
        user = [XmppCenter shareInstance].myJid.user;
    }
    self.msg = msg;
    //头像
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
            weakSelf.ivUserImg.image = headImg;
        });
    });
    
    //sender-receiver处理
    if (msg.isOutgoing) {
        self.containerImageView.image = [self stretchImage:@"SenderTextNodeBkg"];
    }else{
        self.containerImageView.image = [self stretchImage:@"ReceiverTextNodeBkg"];
    }
    self.maskViewImage.image = self.containerImageView.image;
    
    //消息处理
    NSString *chatType = [self.msg.message attributeStringValueForName:@"bodyType"];
    self.ivImg.hidden = YES;
    self.lbContent.hidden = YES;
    if ([chatType integerValue] == MessageTypeText) {//文字
        self.lbContent.text = msg.body;
        self.lbContent.hidden = NO;
    }else if([chatType integerValue] == MessageTypeImage){//图片
        __weak __typeof (self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imgBody = [msg.message attributeStringValueForName:@"imgBody"];
            NSData *data = [[NSData alloc]initWithBase64EncodedString:imgBody options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *calImage = [[UIImage alloc]initWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.ivImg setImage:calImage];
            });
        });
        self.ivImg.hidden = NO;
    }else if([chatType integerValue] == MessageTypeVideo){//视频
        
    }else if([chatType integerValue] == MessageTypeRecord){//语音
        
    }else if([chatType integerValue] == MessageTypeLocation){//位置
        
    }
}

- (UIImage*)stretchImage:(NSString*)name
{
    UIImage *image = nil;
    if (name && name.length > 0) {
        image = [UIImage imageNamed:name];
        CGSize imgSize = image.size;
        CGPoint pt = CGPointMake(.5, .5);
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(imgSize.height * pt.y,
                                                                    imgSize.width * pt.x,
                                                                    imgSize.height * (1 - pt.y),
                                                                    imgSize.width * (1 - pt.x))];
        
        return image;
    }
    return nil;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    NSString *chatType = [self.msg.message attributeStringValueForName:@"bodyType"];
    CGRect r = self.ivUserImg.frame;
    r.origin.x = 10;
    r.origin.y = 15;
    r.size.width = 30*RATIO_WIDHT320;
    r.size.height = r.size.width;
    self.ivUserImg.frame = r;
    
    CGFloat w = 0 ,h = 0;
    if ([chatType integerValue] == MessageTypeText) {//文字
        [self.container.layer.mask removeFromSuperlayer];
        w = [self.lbContent sizeThatFits:CGSizeMake(MAXFLOAT, 14*RATIO_WIDHT320)].width;
        if (w > kMaxContainerWidth) {
            w = kMaxContainerWidth;
        }else{
            w += 30;
        }
        h = [self.lbContent sizeThatFits:CGSizeMake(w-30, MAXFLOAT)].height;
        
        r = self.lbContent.frame;
        r.origin.x = 15;
        r.origin.y = 10;
        r.size.width = w-30;
        r.size.height = h;
        self.lbContent.frame = r;
        h += 20;
    }else if([chatType integerValue] == MessageTypeImage){//图片
        NSString *imgBody = [self.msg.message attributeStringValueForName:@"imgBody"];
        CGSize size = [ChatCell calSize:imgBody];
        r = self.ivImg.frame;
        r.origin.x = 0;
        r.origin.y = 0;
        r.size.width = size.width;
        r.size.height = size.height;
        self.ivImg.frame = r;
        
        w = size.width;
        h = size.height;
        self.container.layer.mask = self.maskViewImage.layer;
    }else if([chatType integerValue] == MessageTypeVideo){//视频
        
    }else if([chatType integerValue] == MessageTypeRecord){//语音
        
    }else if([chatType integerValue] == MessageTypeLocation){//位置
        
    }
    
    r = self.containerImageView.frame;
    r.origin.x = 0;
    r.origin.y = 0;
    r.size.width = w;
    r.size.height = h+10;
    self.containerImageView.frame = r;
    self.maskViewImage.frame = r;
    
    r = self.container.frame;
    r.origin.x = self.ivUserImg.right+15;
    r.origin.y = 15;
    r.size.width = w;
    r.size.height = h;
    self.container.frame = r;
    
    if (self.msg.isOutgoing) {
        r = self.ivUserImg.frame;
        r.origin.x = self.width - 10-self.ivUserImg.width;
        self.ivUserImg.frame = r;
        
        r = self.container.frame;
        r.origin.x = self.ivUserImg.x - r.size.width - 15;
        self.container.frame = r;
    }
}

+ (CGFloat)calHeight:(XMPPMessageArchiving_Message_CoreDataObject *)msg{
    CGFloat height = 15;
    
    
    
    
    NSString *chatType = [msg.message attributeStringValueForName:@"bodyType"];
    if ([chatType integerValue] == MessageTypeText) {//文字
        NSString *str = msg.body;
        UILabel *lbContent = [UILabel new];
        lbContent.font = FONT(14*RATIO_WIDHT320);
        lbContent.numberOfLines = 0;
        lbContent.text = str;
        
        CGFloat w ,h;
        w = [lbContent sizeThatFits:CGSizeMake(MAXFLOAT, 14*RATIO_WIDHT320)].width;
        if (w > kMaxContainerWidth) {
            w = kMaxContainerWidth;
        }else{
            w += 30;
        }
        h = [lbContent sizeThatFits:CGSizeMake(w-30, MAXFLOAT)].height;
        height = h + 35;
    }else if([chatType integerValue] == MessageTypeImage){//图片
        NSString *imgBody = [msg.message attributeStringValueForName:@"imgBody"];
        CGSize size = [ChatCell calSize:imgBody];
        height += size.height;
    }else if([chatType integerValue] == MessageTypeVideo){//视频
        
    }else if([chatType integerValue] == MessageTypeRecord){//语音
        
    }else if([chatType integerValue] == MessageTypeLocation){//位置
        
    }
    
    
    return height;
}

// 根据图片的宽高尺寸设置图片约束
+(CGSize)calSize:(NSString *)str{
    CGFloat standardWidthHeightRatio = MaxChatImageViewWidh / MaxChatImageViewHeight;
    CGFloat widthHeightRatio = 0;
    NSData *data = [[NSData alloc]initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *calImage = [[UIImage alloc]initWithData:data];
    CGFloat h = calImage.size.height;
    CGFloat w = calImage.size.width;
    
    if (w > MaxChatImageViewWidh || w > MaxChatImageViewHeight) {
        
        widthHeightRatio = w / h;
        if (widthHeightRatio > standardWidthHeightRatio) {
            w = MaxChatImageViewWidh;
            h = w * (calImage.size.height / calImage.size.width);
        } else {
            h = MaxChatImageViewHeight;
            w = h * widthHeightRatio;
        }
    }
    return CGSizeMake(w, h);
}
@end
