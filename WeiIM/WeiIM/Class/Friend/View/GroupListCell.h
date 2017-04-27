//
//  GroupListCell.h
//  WeiIM
//
//  Created by zhouMR on 2017/4/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupListCell : UITableViewCell
@property(nonatomic,strong)UIView *vLine;
- (void)updateData:(DDXMLElement*)data;

@end
