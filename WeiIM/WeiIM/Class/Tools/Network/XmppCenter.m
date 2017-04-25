//
//  XmppCenter.m
//  WeiIM
//
//  Created by zhouMR on 2017/4/25.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "XmppCenter.h"

@implementation XmppCenter


+ (instancetype)shareInstance{
    static XmppCenter *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XmppCenter alloc]init];
    });
    return manager;
}

- (id)init{
    if (self = [super init]) {
        [self setupStream];
    }
    return self;
}

- (void)setupStream{
    _xmppStream = [[XMPPStream alloc] init];
    _xmppStream.enableBackgroundingOnSocket = YES;
    // 在多线程中运行，为了不阻塞UI线程，
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 1.心跳
    _xmppAutoPing = [[XMPPAutoPing alloc] init];
    [_xmppAutoPing setPingInterval:100];
    [_xmppAutoPing setRespondsToQueries:YES];
    [_xmppAutoPing activate:_xmppStream];
    [_xmppAutoPing addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    
    // 2.autoReconnect 自动重连
    _xmppReconnect = [[XMPPReconnect alloc] init];
    [_xmppReconnect activate:_xmppStream];
    [_xmppReconnect setAutoReconnect:YES];
    [_xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 3.好友模块 支持我们管理、同步、申请、删除好友
    _xmppRosterMemoryStorage = [[XMPPRosterMemoryStorage alloc] init];
    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterMemoryStorage];
    [_xmppRoster activate:_xmppStream];
    
    //同时给_xmppRosterMemoryStorage 和 _xmppRoster都添加了代理
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //设置好友同步策略,XMPP一旦连接成功，同步好友到本地
    [_xmppRoster setAutoFetchRoster:YES]; //自动同步，从服务器取出好友
    //关掉自动接收好友请求，默认开启自动同意
    [_xmppRoster setAutoAcceptKnownPresenceSubscriptionRequests:NO];
    
    
    // 4.使用电子名片、头像
    XMPPvCardCoreDataStorage *vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _xmppvCardModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:vCardStorage];
    [_xmppvCardModule activate:_xmppStream];
    _xmppAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCardModule];
    [_xmppAvatarModule activate:_xmppStream];
    
    //5.聊天记录
    _messageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    _messageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:self.messageArchivingCoreDataStorage dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 9)];
    _messageArchiving.clientSideMessageArchivingOnly = YES;
    [_messageArchiving activate:_xmppStream];
}

/**
 *  登录方法
 *  @prarm userName 用户名
 *  @prarm userPwd  密码
 */
- (void)loginWithUser:(XMPPJID*)jid withPwd:(NSString*)userPwd withSuccess:(SuccessBlock)sblock withFail:(FailureBlock)fblock{
    self.connectToServerPurpose = ConnectToServerPurposeLogin;
    self.successBlack = sblock;
    self.failureBlack = fblock;
    self.userPassword = userPwd;
    self.myJid = jid;
    [self connection];
}

/**
 *  注册方法
 *  @prarm userName 用户名
 *  @prarm userPwd  密码
 */
- (void)registerWithUser:(XMPPJID *)jid password:(NSString *)password withSuccess:(SuccessBlock)sblock withFail:(FailureBlock)fblock
{
    self.connectToServerPurpose = ConnectToServerPurposeRegister;
    self.successBlack = sblock;
    self.failureBlack = fblock;
    self.userPassword = password;
    self.myJid = jid;
    [self connection];
}

/**
 * 连接服务器
 */
- (void)connection{
    [self.xmppStream setMyJID:self.myJid];
    // 发送请求
    if ([self.xmppStream isConnected] || [self.xmppStream isConnecting]) {
        // 先发送下线状态
        [self goOffLine];
    }
    NSError *error;
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
}

- (void)goOffLine{
    //生成网络状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    //改变通道状态
    [self.xmppStream sendElement:presence];
    //断开链接
    [self.xmppStream disconnect];
}

#pragma mark - XMPPStreamDelegate
- (void)xmppStreamWillConnect:(XMPPStream *)sender {
    NSLog(@"%s--%d|正在连接",__func__,__LINE__);
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
    NSLog(@"%s--%d|连接成功",__func__,__LINE__);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    NSLog(@"%s--%d|连接失败|%@",__func__,__LINE__,error);
    
}

/**
 *  xmpp连接成功之后走这里
 */
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSError *error;
    switch (self.connectToServerPurpose) {
        case ConnectToServerPurposeLogin:
            [self.xmppStream authenticateWithPassword:self.userPassword error:&error];
            break;
        case ConnectToServerPurposeRegister:
            [self.xmppStream registerWithPassword:self.userPassword error:&error];
        default:
            break;
    }
}

/**
 *  密码验证成功（即登录成功）
 */
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.xmppStream sendElement:presence];
    self.successBlack();
}

/**
 *  密码验证失败
 */
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    self.failureBlack(error.description);
}

/**
 *  注册成功
 */
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    self.successBlack();
}

/**
 *  注册失败
 */
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    self.failureBlack(error.description);
}

#pragma mark - XMPPReconnectDelegate
//重新失败时走该方法
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags{
    NSLog(@"%s--%d|",__func__,__LINE__);
}

//接受自动重连
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags{
    NSLog(@"%s--%d|",__func__,__LINE__);
    return TRUE;
}

#pragma mark ===== 好友模块 委托=======
/** 收到出席订阅请求（代表对方想添加自己为好友) */
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    //添加好友一定会订阅对方，但是接受订阅不一定要添加对方为好友
    self.receivePresence = presence;
    NSString *from = presence.from.bare;
    NSRange range = [from rangeOfString:@"@"];
    from = [from substringToIndex:range.location];
    NSString *message = [NSString stringWithFormat:@"【%@】想加你为好友",from];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
    alertView.tag = 100;
    [alertView show];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    //收到对方取消定阅我得消息
    if ([presence.type isEqualToString:@"unsubscribe"]) {
        //从我的本地通讯录中将他移除
        [self.xmppRoster removeUser:presence.from];
    }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            [self.xmppRoster rejectPresenceSubscriptionRequestFrom:self.receivePresence.from];
        } else {
            [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.receivePresence.from andAddToRoster:YES];
        }
    }
}

/**
 * 好友同步结束
 **/
//收到好友列表IQ会进入的方法，并且已经存入我的存储器
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
//    [self changeFriend];
}

// 如果不是初始化同步来的roster,那么会自动存入我的好友存储器
- (void)xmppRosterDidChange:(XMPPRosterMemoryStorage *)sender
{
//    [self changeFriend];
}


#pragma mark - Event 
- (XMPPJID*)getJIDWithUserId:(NSString *)userId{
    NSString *baseStr = [NSString stringWithFormat:@"%@@%@/%@",userId,XMPP_HOST,XMPP_PLATFORM];
    XMPPJID *chatJID = [XMPPJID jidWithString:baseStr];
    return chatJID;
}

- (NSData*)getImageData:(NSString *)userId;
{
    XMPPJID *jid = [self getJIDWithUserId:userId];
    NSData *photoData = [self.xmppAvatarModule photoDataForJID:jid];
    return photoData;
}

@end
