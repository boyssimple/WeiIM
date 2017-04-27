//
//  VCChat.h
//  WeiIM
//
//  Created by zhouMR on 2017/4/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "VCBase.h"
#import <AVFoundation/AVFoundation.h>
@interface VCChat : VCBase
@property (nonatomic, strong) XMPPJID *userJid;

//录音
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSData *recordData;
@end
