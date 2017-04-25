//
//  Global.h
//  AtChat
//
//  Created by zhouMR on 16/11/3.
//  Copyright © 2016年 luowei. All rights reserved.
//

#ifndef Global_h
#define Global_h


#define DEVICE_WIDTH [UIScreen mainScreen].bounds.size.width
#define DEVICE_HEIGHT [UIScreen mainScreen].bounds.size.height
#define RATIO_WIDHT320 [UIScreen mainScreen].bounds.size.width/320.0
#define RATIO_HEIGHT568 [UIScreen mainScreen].bounds.size.height/568.0

#define NAV_STATUS_HEIGHT 64
#define TABBAR_HEIGHT 49

#define FONTSIZE 14

//颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1)
#define RGB3(v) RGB(v,v,v)
#define APPCOLOR RGB(27,214,169)
#define GrayColor RGB3(245)
#define randomColor RGB(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))


#pragma mark --------- 图片
#define IMAGE(img)[UIImage imageNamed:img]

#pragma mark --------- 字体大小
#define FONT(size) [UIFont systemFontOfSize:size]

//XMPP 聊天

#define XMPP_HOST @"123.57.132.48"
#define XMPP_PLATFORM @"IOS"
#define XMPP_TYPE_CHAT @"chat"                //消息类型chat、group
#define XMPP_TYPE_GROUP @"group" 

#endif /* Global_h */
