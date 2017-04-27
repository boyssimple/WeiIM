//
//  NewFriendCell.h
//  WeiIM
//
//  Created by zhouMR on 2017/4/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewFriendCell : UITableViewCell
@property(nonatomic,strong)UIView *vLine;
@property(nonatomic,assign)NSInteger type;
- (void)updateData:(NSInteger)type;
+ (CGFloat)calHeight;
@end
