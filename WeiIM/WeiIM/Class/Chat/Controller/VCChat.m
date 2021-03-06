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
#import "VCMap.h"
#import "VCNavBase.h"
#import "MapInfo.h"
#import "VCMapShow.h"

@interface VCChat ()<UITableViewDelegate,UITableViewDataSource,XMPPStreamDelegate,InputTextBarDelegate,
    UIImagePickerControllerDelegate,UINavigationControllerDelegate,ChatCellDelegate,AVAudioPlayerDelegate>
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) InputTextBar *inputBar;
@property (nonatomic,strong) UIImagePickerController *imagePicker;
@property (nonatomic,strong) UIImagePickerController *picker;

@end

@implementation VCChat

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

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
    self.operation = OPERATIONIMAGESELECT;
    [self presentViewController:self.picker animated:YES completion:nil];
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

//录音开始
-(void)recordDownAction{
    NSError *error = nil;
    
    //激活AVAudioSession
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (session != nil) {
        [session setActive:YES error:nil];
    }else {
        NSLog(@"session error: %@",error);
    }
    
    //设置AVAudioRecorder类的setting参数
    NSDictionary *recorderSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:16000.0],AVSampleRateKey,
                                      [NSNumber numberWithInt:kAudioFormatAppleIMA4],AVFormatIDKey,
                                      [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                                      [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey,
                                      nil];
    
    //实例化AVAudioRecorder对象
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.url settings:recorderSettings error:&error];
    if (error) {
        NSLog(@"recorder error: %@", error);
    }
    //开始录音
    [self.recorder record];
}

//录音完成
-(void)recordUpAction{
    [self.recorder stop];
    self.recorder = nil;
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:self.url options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    if (audioDurationSeconds >= 0.01) {
        //录音完成发送
        NSData *data = [[NSData alloc]initWithContentsOfURL:self.url];
        [self sendRecordMessageWithData:data bodyName:@"[语音]" withTime:audioDurationSeconds];
    }
}

/** 发送录音 */
- (void)sendRecordMessageWithData:(NSData *)data bodyName:(NSString *)name withTime:(float)time
{
    
    NSString *base64str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    XMPPMessage *message = [XMPPMessage messageWithType:XMPP_TYPE_CHAT to:self.userJid];
    [message addAttributeWithName:@"bodyType" stringValue:[NSString stringWithFormat:@"%zi",MessageTypeRecord]];
    [message addAttributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%.f",ceilf(time)]];
    [message addAttributeWithName:@"record" stringValue:base64str];
    [message addBody:name];
    [[XmppCenter shareInstance].xmppStream sendElement:message];
    
}

/** 发送位置 */
- (void)sendRecordMessageWithLocation:(MapInfo*)info;
{
    NSData *data = UIImagePNGRepresentation(info.img);
    NSString *base64str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    XMPPMessage *message = [XMPPMessage messageWithType:XMPP_TYPE_CHAT to:self.userJid];
    [message addAttributeWithName:@"bodyType" stringValue:[NSString stringWithFormat:@"%zi",MessageTypeLocation]];
    [message addAttributeWithName:@"location" stringValue:[NSString stringWithFormat:@"%@",info.name]];
    [message addAttributeWithName:@"address" stringValue:[NSString stringWithFormat:@"%@",info.address]];
    [message addAttributeWithName:@"latitude" stringValue:[NSString stringWithFormat:@"%zi",info.latitude]];
    [message addAttributeWithName:@"longitude" stringValue:[NSString stringWithFormat:@"%zi",info.longitude]];
    [message addAttributeWithName:@"image" stringValue:base64str];
    [message addBody:@"[位置]"];
    [[XmppCenter shareInstance].xmppStream sendElement:message];
    
}

- (void)playRecord:(NSString*)dataStr{
    self.player = nil;
    NSData *data = [[NSData alloc]initWithBase64EncodedString:dataStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (data) {
        self.recordData = data;
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,sizeof (audioRouteOverride),&audioRouteOverride);
        [self.player play];
    }
}

- (void)takePicture {
    self.operation = OPERATIONIMAGEMAKEPHOTO;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
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
    cell.delegate = self;
    cell.index = indexPath.row;
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
        if (buttonIndex == 1) {//录音
            [self recordDownAction];
        }else{                 //录音完成
            [self recordUpAction];
        }
    }else if(type == 3){    //功能
        if(buttonIndex == 1){//图片
            [self selectImg];
        }else if(buttonIndex == 2){//相机
            [self takePicture];
        }else if(buttonIndex == 3){//视频聊天
            
        }else if(buttonIndex == 4){//位置
            __weak __typeof (self)weakSelf = self;
            VCMap *vc = [[VCMap alloc]initWithBlock:^(MapInfo *loc) {
                [weakSelf sendRecordMessageWithLocation:loc];
            }];
            VCNavBase *nav = [[VCNavBase alloc]initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
}

- (void)clickChatCell:(InputTextBar *)bar withOpen:(BOOL)open{
    CGFloat h = DEVICE_HEIGHT - NAV_STATUS_HEIGHT - [InputTextBar calHeight];
    CGFloat hx = h - 200;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.table.frame;
        if(open){
            f.size.height = hx;
        }else{
            f.size.height = h;
        }
        self.table.frame = f;
    } completion:^(BOOL finished) {
        
    }];
    [self scrollToBottom];
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
    UIImage *image;
    if (self.operation == OPERATIONIMAGEMAKEPHOTO) {
        // 如果允许编辑则获得编辑后的照片，否则获取原始照片
        if (self.imagePicker.allowsEditing) {
            // 获取编辑后的照片
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        }else{
            // 获取原始照片
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
    }else{
        
        image = info[UIImagePickerControllerEditedImage];
    }
    if (image) {
        NSData *data = UIImageJPEGRepresentation(image,0.3);
        [self sendMessageWithData:data bodyName:@"[图片]"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark - ChatCellDelegate
- (void)chatCell:(ChatCell *)chat clickIndex:(NSInteger)index withType:(NSInteger)type{
    if (type == 1) {
        XMPPMessageArchiving_Message_CoreDataObject *msg = [self.dataSource objectAtIndex:index];
        NSString *chatType = [msg.message attributeStringValueForName:@"bodyType"];
        if ([chatType integerValue] == MessageTypeRecord) {
            NSString *record = [msg.message attributeStringValueForName:@"record"];
            if(record){
                [self playRecord:record];
            }
        }else if([chatType integerValue] == MessageTypeLocation){
            VCMapShow *vc = [[VCMapShow alloc]init];
            CGFloat lon = [[msg.message attributeStringValueForName:@"longitude"]floatValue];
            CGFloat lat = [[msg.message attributeStringValueForName:@"latitude"]floatValue];
            MapInfo *info = [[MapInfo alloc]init];
            info.longitude = lon;
            info.latitude = lat;
            vc.info = info;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"%s",__func__);
    self.player = nil;
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

- (NSURL*)url{
    if (!_url) {
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *urlPath = [tmpDir stringByAppendingString:@"record.caf"];
        _url = [NSURL fileURLWithPath:urlPath];
    }
    return _url;
}

- (AVAudioPlayer *)player{
    if (!_player) {
        NSError *error = nil;
        _player = [[AVAudioPlayer alloc] initWithData:self.recordData error:&error];//使用NSData创建
        _player.volume = 1.0;
        
        _player.delegate = self;
        if (error) {
            NSLog(@"player error:%@",error);
        }
    }
    return _player;
}

- (UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc]init];
        // 判断现在可以获得多媒体的方式
        if ([UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]) {
            // 设置image picker的来源，这里设置为摄像头
            _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            // 设置使用哪个摄像头，这里设置为后置摄像头
            _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        }
        else {
            _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        // 允许编辑
        _imagePicker.allowsEditing = YES;
        // 设置代理，检测操作
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

- (UIImagePickerController*)picker{
    if (!_picker) {
        _picker = [[UIImagePickerController alloc]init];
        // 允许编辑
        _picker.allowsEditing=YES;
        // 设置代理，检测操作
        _picker.delegate=self;
    }
    return _picker;
}
@end
