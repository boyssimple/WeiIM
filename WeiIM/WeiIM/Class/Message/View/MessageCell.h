//
//  MessageCell.h
//  WeiIM
//
//  Created by zhouMR on 2017/4/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell
@property (nonatomic, strong) UIView  *vLine;
+ (CGFloat)calHeight;
- (void)updateData:(XMPPMessageArchiving_Contact_CoreDataObject*)data;
@end
