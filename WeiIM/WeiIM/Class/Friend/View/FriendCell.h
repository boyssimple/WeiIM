//
//  FriendCell.h
//  WeiIM
//
//  Created by simple on 17/4/25.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell
- (void)updateData:(XMPPUserMemoryStorageObject*)data;
- (void)updateDataElse:(NSDictionary*)data;
- (void)updateData;
@end
