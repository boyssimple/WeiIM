//
//  VCMeTab.m
//  LifeChat
//
//  Created by simple on 16/4/23.
//  Copyright © 2016年 com.sean. All rights reserved.
//

#import "VCMine.h"
#import "VCLogin.h"

@interface VCMine ()
@property (nonatomic,strong) UIImageView *img;
@end

@implementation VCMine

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _img = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 50, 50)];
    [_img setImage:IMAGE(@"DefaultProfileHead")];
    _img.layer.cornerRadius = 25;
    _img.layer.masksToBounds = TRUE;
    _img.userInteractionEnabled = TRUE;
    [self.view addSubview:_img];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(_img.left+10, 35, 150, 15)];
    label.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label];
    
    UIButton *exitBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, _img.top+50, DEVICE_WIDTH-30, 40)];
    [exitBtn setBackgroundColor:RGB(241, 71, 4)];
    [exitBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    exitBtn.layer.cornerRadius = 3;
    exitBtn.titleLabel.font = FONT(FONTSIZE);
    [self.view addSubview:exitBtn];
    
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
            weakSelf.img.image = headImg;
        });
    });
    label.text = [XmppCenter shareInstance].myJid.user;
}

-(void)exitAction{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定退出？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [[XmppCenter shareInstance] goOffLine];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"退出登录...";
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            VCLogin *login = [[VCLogin alloc]init];
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            window.rootViewController = login;
        });
    }
}
@end
