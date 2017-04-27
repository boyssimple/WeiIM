//
//  VCNewFriend.m
//  WeiIM
//
//  Created by zhouMR on 2017/4/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "VCGroupList.h"
#import "GroupListCell.h"
#import "ActionSheet.h"
#import <XMPPFramework/XMPPRoomCoreDataStorage.h>
#import <XMPPFramework/XMPPRoomMemoryStorage.h>

@interface VCGroupList ()<UITableViewDelegate,UITableViewDataSource,ActionSheetDelegate,UIAlertViewDelegate,XMPPRoomDelegate>
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic,strong)XMPPRoom *xmppRoom;
@property (nonatomic,strong)XMPPRoomCoreDataStorage *xmppRoomStorage;

@end

@implementation VCGroupList

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"群聊";
    [self.view addSubview:self.table];
    _dataSource = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRoomsResult:) name:XMPP_GET_GROUPS object:nil];
    [[XmppCenter shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ShareImg"] style:UIBarButtonItemStylePlain target:self action:@selector(action)];
}

- (void)viewWillAppear:(BOOL)animated{
    [self getRoomList];
}

#pragma mark - Event
- (void)action{
    ActionSheet *action = [[ActionSheet alloc]initWithActions:@[@{@"name":@"创建"},@{@"name":@"加入"}]];
    action.delegate = self;
    [action show];
}

- (void)getRoomsResult:(NSNotification *)notification{
    NSLog(@"%@",notification.object);
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:[notification object]];
    [self.table reloadData];
}

/**
 * 获取群列表
 */
- (void)getRoomList{
    NSXMLElement *queryElement= [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    NSXMLElement *iqElement = [NSXMLElement elementWithName:@"iq"];
    [iqElement addAttributeWithName:@"type" stringValue:@"get"];
    [iqElement addAttributeWithName:@"from" stringValue:[XmppCenter shareInstance].xmppStream.myJID.bare];
    NSString *service = [NSString stringWithFormat:XMPP_GROUPSERVICE];
    [iqElement addAttributeWithName:@"to" stringValue:service];
    [iqElement addAttributeWithName:@"id" stringValue:@"getMyRooms"];
    [iqElement addChild:queryElement];
    [[XmppCenter shareInstance].xmppStream sendElement:iqElement];
    
}

- (void)creatRoomTest{
    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"请输入群名" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
    alertV.tag = 1;
    alertV.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertV show];
}

#pragma mark 查找特定房间
-(void)fetchRoomName:(NSString*)roomName{
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#info"];
    //conference 原生的
    NSString *roomId = [NSString stringWithFormat:@"%@@%@",roomName, XMPP_GROUPSERVICE];
    XMPPJID* proxyCandidateJID = [XMPPJID jidWithString:roomId];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:proxyCandidateJID  elementID:@"disco" child:query];
    
    [[XmppCenter shareInstance].xmppStream sendElement:iq];
    
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50*RATIO_WIDHT320;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupListCell"];
    DDXMLElement *item = self.dataSource[indexPath.row];
    [cell updateData:item];
    
    if (indexPath.row == self.dataSource.count-1) {
        cell.vLine.hidden = YES;
    }else{
        cell.vLine.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    //    XMPPMessageArchiving_Contact_CoreDataObject *user = [self.dataSource objectAtIndex:indexPath.row];
    //    VCChat *vc = [[VCChat alloc]init];
    //    vc.toUser = user.bareJid;
    //    vc.title = user.bareJid.user;
    //    vc.hidesBottomBarWhenPushed = YES;
    //    [self.navigationController pushViewController:vc animated:TRUE];
}

#pragma mark - ActionSheetDelegate
- (void)actionSheetClickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
    }else{
        [self creatRoomTest];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1 && buttonIndex == 1) {
        NSString *roomName = [alertView textFieldAtIndex:0].text;
        NSString *roomId = [NSString stringWithFormat:@"%@@%@",roomName, XMPP_GROUPSERVICE];
        XMPPJID *roomJID = [XMPPJID jidWithString:roomId];
        XMPPRoomMemoryStorage *xmppRoomStorage = [[XMPPRoomMemoryStorage alloc] init];
        XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
        [xmppRoom activate:[XmppCenter shareInstance].xmppStream];
        [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
        [xmppRoom joinRoomUsingNickname:[XmppCenter shareInstance].xmppStream.myJID.user history:nil];
        [xmppRoom configureRoomUsingOptions:nil];
        
        [self fetchRoomName:roomName];
    }
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    self.xmppRoom = sender;
    [self configNewRoom:sender];//可以自定义房间配置 此处可以自定义
    [self setUpJoinAndCreatRoomConfig];
    NSLog(@"加入房间成功");
    [self getRoomList];
}

- (void)setUpJoinAndCreatRoomConfig{
    [self.xmppRoom fetchConfigurationForm];
    [self.xmppRoom fetchBanList];
    [self.xmppRoom fetchMembersList];
    
}

- (void)configNewRoom:(XMPPRoom *)xmppRoom
{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"xmlns:@"jabber:x:data"];
    NSXMLElement *p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_persistentroom"];//永久房间
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_maxusers"];//最大用户
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"100"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_changesubject"];//允许改变主题
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_publicroom"];//公共房间
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"0"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_allowinvites"];//允许邀请
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_enablelogging"];//登录房间会话
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_roomadmins"];//
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field"];
    [p addAttributeWithName:@"var" stringValue:@"muc#maxhistoryfetch"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]]; //history
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field"];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_Unmoderatedroom"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    [xmppRoom configureRoomUsingOptions:x];
}


- (void)xmppRoom:(XMPPRoom *)sender didFailToDestroy:(XMPPIQ *)iqError{
    
}


- (UITableView*)table{
    if (!_table) {
        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-NAV_STATUS_HEIGHT) style:UITableViewStylePlain];
        [_table registerClass:[GroupListCell class] forCellReuseIdentifier:@"GroupListCell"];
        _table.delegate = self;
        _table.dataSource = self;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _table;
}

@end
