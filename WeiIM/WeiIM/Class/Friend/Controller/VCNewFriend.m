//
//  VCNewFriend.m
//  WeiIM
//
//  Created by zhouMR on 2017/4/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "VCNewFriend.h"
#import "NewFriendCell.h"

@interface VCNewFriend ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation VCNewFriend

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"新的朋友";
    [self.view addSubview:self.table];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [NewFriendCell calHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewFriendCell"];
    if(indexPath.row < 3){
        [cell updateData:2];
    }else{
        [cell updateData:1];
    }
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


- (UITableView*)table{
    if (!_table) {
        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-NAV_STATUS_HEIGHT) style:UITableViewStylePlain];
        [_table registerClass:[NewFriendCell class] forCellReuseIdentifier:@"NewFriendCell"];
        _table.delegate = self;
        _table.dataSource = self;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _table;
}

@end
