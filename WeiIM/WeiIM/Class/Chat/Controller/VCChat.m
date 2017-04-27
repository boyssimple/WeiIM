//
//  VCNewFriend.m
//  WeiIM
//
//  Created by zhouMR on 2017/4/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "VCChat.h"
#import "ChatCell.h"
#import "InputTextBar.h"

@interface VCChat ()<UITableViewDelegate,UITableViewDataSource,XMPPStreamDelegate,InputTextBarDelegate,
    UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) InputTextBar *inputBar;

@end

@implementation VCChat

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.userJid.user;
    [self.view addSubview:self.table];
    [self.view addSubview:self.inputBar];
    _dataSource = [NSMutableArray array];
    
    
    [[XmppCenter shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self reloadMessages];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - Events

-(void)scrollToBottom{
    if (self.dataSource.count > 0) {
        [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

/**
 * 重新获取历史记录
 */
- (void)reloadMessages{
    NSManagedObjectContext *context = [XmppCenter shareInstance].messageArchivingCoreDataStorage.mainThreadManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    //创建查询条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@ and streamBareJidStr = %@", self.userJid.bare, [XmppCenter shareInstance].myJid.bare];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    //    fetchRequest.fetchOffset = 0;
    //    fetchRequest.fetchLimit = 10;
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if(fetchedObjects.count > 0){
        
        if (self.dataSource != nil) {
            if ([self.dataSource count] > 0) {
                [self.dataSource removeAllObjects];
            }
            [self.dataSource addObjectsFromArray:fetchedObjects];
            
            [self reload];
        }
    }
}

- (void)reload{
    [self.table reloadData];
    [self scrollToBottom];
}

//选择图片
- (void)selectImg{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

/** 发送图片 */
- (void)sendMessageWithData:(NSData *)data bodyName:(NSString *)name
{
    NSString *base64str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    XMPPMessage *message = [XMPPMessage messageWithType:XMPP_TYPE_CHAT to:self.userJid];
    [message addAttributeWithName:@"bodyType" stringValue:[NSString stringWithFormat:@"%zi",MessageTypeImage]];
    [message addAttributeWithName:@"imgBody" stringValue:base64str];
    [message addBody:name];
    [[XmppCenter shareInstance].xmppStream sendElement:message];
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPMessageArchiving_Message_CoreDataObject *msg = [self.dataSource objectAtIndex:indexPath.row];
    return [ChatCell calHeight:msg];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    XMPPMessageArchiving_Message_CoreDataObject *msg = [self.dataSource objectAtIndex:indexPath.row];
    [cell updateData:msg];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    [self.view endEditing:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [self.view endEditing:NO];
}

#pragma mark - 监听事件
- (void) keyboardWillChangeFrame:(NSNotification *)note{
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat transformY = keyboardFrame.origin.y - self.view.height;
    CGFloat h = DEVICE_HEIGHT - NAV_STATUS_HEIGHT - [InputTextBar calHeight];
    CGFloat hx = h +transformY-NAV_STATUS_HEIGHT;
    [UIView animateWithDuration:duration animations:^{
        self.inputBar.transform = CGAffineTransformMakeTranslation(0, transformY-NAV_STATUS_HEIGHT);
        CGRect f = self.table.frame;
        if(transformY < 0){
            f.size.height = hx;
        }else{
            f.size.height = h;
        }
        self.table.frame = f;
    } completion:^(BOOL finished) {
    }];
    [self scrollToBottom];
}


#pragma mark - Message

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self reloadMessages];
    });
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    NSLog(@"%s__%d|发送失败",__func__,__LINE__);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    if (message.body) {
        NSLog(@"%s__%d|收到消息---%@",__func__,__LINE__,message.body);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self reloadMessages];
        });
    }
}

#pragma mark - InputTextBarDelegate
- (void)inputText:(InputTextBar *)bar clickedButtonAtIndex:(NSInteger)buttonIndex withType:(NSInteger)type{
    if(type == 1){          //表情
    
    }else if(type == 2){    //语音
        
    }else if(type == 3){    //功能
        if(buttonIndex == 1){
            [self selectImg];
        }else if(buttonIndex == 2){
            
        }else if(buttonIndex == 3){
            
        }else if(buttonIndex == 4){
            
        }
    }
}

- (void)sendMessage:(NSString*)message{
    if (![message isEqualToString:@""]) {
        XMPPMessage *msg = [XMPPMessage messageWithType:XMPP_TYPE_CHAT to:self.userJid];
        [msg addAttributeWithName:@"bodyType" stringValue:[NSString stringWithFormat:@"%zi",MessageTypeText]];
        [msg addBody:message];
        [[XmppCenter shareInstance].xmppStream sendElement:msg];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *data = UIImageJPEGRepresentation(image,0.3);
    [self sendMessageWithData:data bodyName:@"[图片]"];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Getter Setter
- (UITableView*)table{
    if (!_table) {
        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-NAV_STATUS_HEIGHT-[InputTextBar calHeight]) style:UITableViewStylePlain];
        [_table registerClass:[ChatCell class] forCellReuseIdentifier:@"ChatCell"];
        _table.delegate = self;
        _table.dataSource = self;
        _table.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _table;
}

- (InputTextBar*)inputBar{
    if(!_inputBar){
       _inputBar = [[InputTextBar alloc]initWithFrame:CGRectMake(0, self.table.bottom, DEVICE_WIDTH, [InputTextBar calHeight])];
       _inputBar.delegate = self;
    }
    return _inputBar;
}
@end
