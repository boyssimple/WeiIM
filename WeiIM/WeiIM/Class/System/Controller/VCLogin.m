//
//  VCLogin.m
//  LifeChat
//
//  Created by simple on 16/4/23.
//  Copyright © 2016年 com.sean. All rights reserved.
//

#import "VCLogin.h"
#import "VCMain.h"

@interface VCLogin ()<UITextFieldDelegate>
@property(nonatomic,strong)UILabel *lbUserName;
@property(nonatomic,strong)UILabel *lbUserPwd;
@property(nonatomic,strong)UITextField *tfUserName;
@property(nonatomic,strong)UITextField *tfUserPwd;
@property(nonatomic,strong)UIButton *btnLogin;

@property(nonatomic,strong)UIImageView *ivLogo;
@property(nonatomic,strong)UIView *vBg;
@property(nonatomic,strong)UIView *vLine;
@end

@implementation VCLogin

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMain];
}

- (void)initMain{
    self.navigationController.navigationBarHidden = TRUE;
    [self.view setBackgroundColor:APPCOLOR];
    
    [self.view addSubview:self.ivLogo];
    [self.view addSubview:self.vBg];
    [self.view addSubview:self.btnLogin];
    
    //读取沙盒
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *userName = [user objectForKey:@"userName"];
    NSString *userPassword = [user objectForKey:@"userPassword"];
    if (userName != nil) {
        self.tfUserName.text = userName;
    }
    if (userPassword != nil) {
        self.tfUserPwd.text = userPassword;
    }

}

#pragma mark - Event

-(void)loginAction{
    NSString *username = self.tfUserName.text;
    NSString *password = self.tfUserPwd.text;
    
    NSString *message = nil;
    if (username.length < 3) {
        message = @"用户名不能少于6位";
    } else if (password.length < 6) {
        message = @"密码不能少于6位";
    }
    
    if (message.length > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
        [alertView show];
    } else {
        //登录
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"登录中...";
        XMPPJID *jid = [[XmppCenter shareInstance] getJIDWithUserId:username];
        [[XmppCenter shareInstance] loginWithUser:jid withPwd:password withSuccess:^{
            NSLog(@"%s__%d__| 登陆成功", __FUNCTION__, __LINE__);
            
            //存入沙盒
            NSString *username = self.tfUserName.text;
            NSString *password = self.tfUserPwd.text;
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:username forKey:@"userName"];
            [userDefaults setObject:password forKey:@"userPassword"];
            [userDefaults synchronize];
            
            
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            VCMain *main = [[VCMain alloc]init];
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            window.rootViewController = main;
        } withFail:^(NSString *error) {
            NSLog(@"%s__%d__|", __FUNCTION__, __LINE__);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"用户名或密码错误" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
        }];
    }
}


#pragma mark - geter seter

-(UILabel *)lbUserName{
    if (!_lbUserName) {
        _lbUserName = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 60, 46)];
        _lbUserName.text = @"帐号：";
        _lbUserName.textColor = RGB3(164);
        _lbUserName.font = FONT(FONTSIZE);
    }
    return _lbUserName;
}

-(UILabel *)lbUserPwd{
    if (!_lbUserPwd) {
        _lbUserPwd = [[UILabel alloc]initWithFrame:CGRectMake(15, self.vLine.top, 60, 46)];
        _lbUserPwd.text = @"密码：";
        _lbUserPwd.textColor = RGB3(164);
        _lbUserPwd.font = FONT(FONTSIZE);
    }
    return _lbUserPwd;
}

-(UITextField *)tfUserName{
    if (!_tfUserName) {
        _tfUserName = [[UITextField alloc]initWithFrame:CGRectMake(self.lbUserName.left, 0, self.vBg.width-self.lbUserName.left-15 , 46)];
        //        _tfUserName.text = @"admin";
        _tfUserName.delegate = self;
    }
    return _tfUserName;
}

-(UITextField *)tfUserPwd{
    if (!_tfUserPwd) {
        _tfUserPwd = [[UITextField alloc]initWithFrame:CGRectMake(self.tfUserName.x, self.lbUserPwd.y, self.tfUserName.width, self.tfUserName.height)];
        _tfUserPwd.delegate = self;
        //        _tfUserPwd.text = @"12345678";
        _tfUserPwd.secureTextEntry = TRUE;
    }
    return _tfUserPwd;
}

-(UIButton *)btnLogin{
    if (!_btnLogin) {
        _btnLogin = [[UIButton alloc]initWithFrame:CGRectMake(15, self.vBg.top+30, DEVICE_WIDTH-30, 40)];
        [_btnLogin setBackgroundColor:RGB(4, 241, 189)];
        [_btnLogin setTitle:@"登录" forState:UIControlStateNormal];
        [_btnLogin addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        _btnLogin.layer.cornerRadius = 6;
        _btnLogin.titleLabel.font = FONT(FONTSIZE);
    }
    return _btnLogin;
}

-(UIView *)vLine{
    if (!_vLine) {
        _vLine = [[UIView alloc]initWithFrame:CGRectMake(10, self.lbUserName.top, self.vBg.width-20, 0.5)];
        [_vLine setBackgroundColor:RGB3(234)];
    }
    return _vLine;
}

-(UIImageView *)ivLogo{
    if (!_ivLogo) {
        _ivLogo = [[UIImageView alloc]init];
        [_ivLogo setImage:IMAGE(@"LoginLogo")];
        _ivLogo.frame = CGRectMake(0, 100, 113, 110);
        _ivLogo.center = CGPointMake(self.view.center.x, _ivLogo.center.y);
    }
    return _ivLogo;
}

-(UIView *)vBg{
    if (!_vBg) {
        _vBg = [[UIView alloc]init];
        [_vBg setBackgroundColor:[UIColor whiteColor]];
        _vBg.layer.cornerRadius = 6;
        _vBg.layer.masksToBounds = TRUE;
        _vBg.frame = CGRectMake(15, self.ivLogo.top+30, DEVICE_WIDTH-30, 93);
        
        
        [_vBg addSubview:self.lbUserName];
        [_vBg addSubview:self.lbUserPwd];
        [_vBg addSubview:self.vLine];
        [_vBg addSubview:self.tfUserName];
        [_vBg addSubview:self.tfUserPwd];
    }
    return _vBg;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.tfUserName resignFirstResponder];
    [self.tfUserPwd resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    
}
@end
