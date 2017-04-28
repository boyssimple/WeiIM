//
//  VCMap.h
//  WeiIM
//
//  Created by zhouMR on 2017/4/28.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "VCBase.h"
#import <MapKit/MapKit.h>
#import "MapInfo.h"
@interface VCMap : VCBase
@property (nonatomic,copy)void(^mapBlock)(MapInfo*loc);
- (instancetype)initWithBlock:(void(^)(MapInfo*loc))block;
@end
