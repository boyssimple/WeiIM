//
//  MapInfo.h
//  MapDemo
//
//  Created by zhouMR on 16/11/7.
//  Copyright © 2016年 luowei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapInfo : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, assign) CGFloat latitude; //!< 纬度（垂直方向）
@property (nonatomic, assign) CGFloat longitude; //!< 经度（水平方向）
@property (nonatomic, strong) UIImage *img;
@end
