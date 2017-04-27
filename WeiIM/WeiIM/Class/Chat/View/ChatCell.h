//
//  ChatCell.h
//  WeiIM
//
//  Created by zhouMR on 2017/4/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatCellDelegate;
@interface ChatCell : UITableViewCell
@property (nonatomic,assign)   NSInteger type;
@property (nonatomic,assign)   NSInteger index;
@property (nonatomic,weak)   id<ChatCellDelegate> delegate;
@property (nonatomic, strong) XMPPMessageArchiving_Message_CoreDataObject *msg;
-(void)updateData:(XMPPMessageArchiving_Message_CoreDataObject *)msg;
+ (CGFloat)calHeight:(XMPPMessageArchiving_Message_CoreDataObject *)msg;
@end

@protocol ChatCellDelegate <NSObject>

- (void)chatCell:(ChatCell *)chat clickIndex:(NSInteger)index withType:(NSInteger)type;

@end
