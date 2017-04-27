//
//  XmppCenter.h
//  WeiIM
//
//  Created by zhouMR on 2017/4/25.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessBlock)(void);
typedef void(^FailureBlock)(NSString *error);
// 枚举
typedef NS_ENUM(NSInteger, ConnectToServerPurpose)
{
    ConnectToServerPurposeLogin,
    ConnectToServerPurposeRegister
};

@interface XmppCenter : NSObject<XMPPStreamDelegate,XMPPRosterDelegate,XMPPRosterMemoryStorageDelegate,XMPPReconnectDelegate,UIAlertViewDelegate,XMPPRoomDelegate>

@property (nonatomic, strong) XMPPStream *xmppStream;
//操作
@property (nonatomic, assign) ConnectToServerPurpose connectToServerPurpose;
//自动重连
@property (nonatomic,strong)XMPPReconnect *xmppReconnect;
//定时发送心跳包
@property (nonatomic, strong) XMPPAutoPing *xmppAutoPing;
//花名册
@property (nonatomic,strong)XMPPRoster *xmppRoster;
//聊天内容
@property (nonatomic,strong)XMPPRosterMemoryStorage *xmppRosterMemoryStorage;
//头像模块
@property (nonatomic, strong) XMPPvCardAvatarModule *xmppAvatarModule;
//电子身份模块
@property (nonatomic, strong) XMPPvCardTempModule *xmppvCardModule;
//消息记录
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *messageArchivingCoreDataStorage;
//消息记录
@property (nonatomic, strong) XMPPMessageArchiving *messageArchiving;
//好友状态
@property (nonatomic,strong)XMPPPresence *receivePresence;


@property (nonatomic, strong) XMPPJID  *myJid;
@property (nonatomic, strong) NSString *userPassword;
@property (nonatomic,strong)  NSMutableArray *friends;
@property (nonatomic, copy)   SuccessBlock successBlack;
@property (nonatomic, copy)   FailureBlock failureBlack;

+ (instancetype)shareInstance;

//登录方法
- (void)loginWithUser:(XMPPJID*)jid withPwd:(NSString*)userPwd withSuccess:(SuccessBlock)sblock withFail:(FailureBlock)fblock;
//注册方法
- (void)registerWithUser:(XMPPJID *)jid password:(NSString *)password withSuccess:(SuccessBlock)sblock withFail:(FailureBlock)fblock;
//根据userid返回xmppjid
- (XMPPJID*)getJIDWithUserId:(NSString *)userId;
//下线
- (void)goOffLine;
//根据userid获取头像
- (NSData*)getImageData:(NSString *)userId;
//添加好友
- (void)addFriendById:(NSString*)name;
@end
