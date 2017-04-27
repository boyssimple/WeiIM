//
//  VCFriend.m
//  WeiIM
//
//  Created by zhouMR on 2017/4/25.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "VCFriend.h"
#import "VCAddFriend.h"
#import "FriendCell.h"
#import "VCNewFriend.h"
#import "VCGroupList.h"
#import "VCChat.h"

@interface VCFriend ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation VCFriend

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addRightButton];
    [self.view addSubview:self.table];
    self.dataSource = [XmppCenter shareInstance].friends;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rosterChange) name:XMPP_Friends_Change object:nil];
}

#pragma mark - Event 
- (void)rosterChange
{
    if ([XmppCenter shareInstance].friends.count) {
        self.dataSource = [XmppCenter shareInstance].friends;
        [self.table reloadData];
    }
}

- (void)addRightButton{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addUser)];
}


- (void)addUser{
    VCAddFriend *vc = [[VCAddFriend alloc]init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:TRUE];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"FriendCell";
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[FriendCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [cell updateDataElse:@{@"img":@"NewFriend",@"name":@"新的朋友"}];
        }else{
            [cell updateDataElse:@{@"img":@"GroupChat",@"name":@"群聊"}];
        }
    }else{
        XMPPUserMemoryStorageObject *data = [self.dataSource objectAtIndex:indexPath.row];
        [cell updateData:data];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60*RATIO_WIDHT320;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 0;
    }
    return 25*RATIO_WIDHT320;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0)];
    header.backgroundColor = GrayColor;
    UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, header.width-20, 25*RATIO_WIDHT320)];
    lb.font = FONT((FONTSIZE-2)*RATIO_WIDHT320);
    lb.text = @"好友";
    [header addSubview:lb];
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            VCNewFriend *vc = [[VCNewFriend alloc]init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:TRUE];
        }else if (indexPath.row == 1) {
            VCGroupList *vc = [[VCGroupList alloc]init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:TRUE];
        }
    }else{
        XMPPUserMemoryStorageObject *data = [self.dataSource objectAtIndex:indexPath.row];
        VCChat *vc = [[VCChat alloc]init];
        vc.userJid = data.jid;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:TRUE];
    }
}

#pragma mark - Geter Seter

- (UITableView*)table{
    if (!_table) {
        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT) style:UITableViewStylePlain];
        _table.delegate = self;
        _table.dataSource = self;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;;
    }
    return _table;
}
@end
