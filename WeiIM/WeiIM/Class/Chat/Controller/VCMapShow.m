//
//  VCMap.m
//  WeiIM
//
//  Created by zhouMR on 2017/4/28.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "VCMapShow.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "ReGeocodeAnnotation.h"
#import "MANaviAnnotationView.h"
@interface VCMapShow ()<AMapSearchDelegate,AMapLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,MAMapViewDelegate>{
    
    UIImageView *_bomeImage;
}
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, strong) AMapReGeocodeSearchRequest *regeo;
@property (nonatomic, strong) CLLocation *loc;
@property (nonatomic, strong) NSMutableArray *datas;
@end

@implementation VCMapShow

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"位置";
    self.loc = [[CLLocation alloc]initWithLatitude:self.info.latitude longitude:self.info.longitude];
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    self.mapView.showsUserLocation = YES;//这句就是开启定位
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.zoomLevel = 13.5;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow; // 追踪用户位置.
    ///把地图添加至view
    [self.view addSubview:self.mapView];
    
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    self.regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.datas = [NSMutableArray array];
    
    [self initBomeImage];
}


//放置中间大头针
-(void)initBomeImage
{
    if (_bomeImage==nil) {
        
        _bomeImage=[[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH/2-25, self.mapView.frame.size.height/2-79, 50, 50)];
        _bomeImage.image=[UIImage imageNamed:@"pic_pin_serach_MapModel"];
    }
    [_mapView addSubview:_bomeImage];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.locationManager startUpdatingLocation];
}


-(void) hehe {
    NSLog(@"1--location:{lat:%f; lon:%f}", self.loc.coordinate.latitude, self.loc.coordinate.longitude);
    
    self.regeo.location = [AMapGeoPoint locationWithLatitude:self.loc.coordinate.latitude longitude:self.loc.coordinate.longitude];
    self.regeo.requireExtension = YES;
    
    //发起逆地理编码
    [self.search AMapReGoecodeSearch:self.regeo];
    
    [self reloadSearch];
    
}



- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    NSLog(@"我被动了");
    CLLocationCoordinate2D centerCoordinate = mapView.region.center;
    NSLog(@" regionDidChangeAnimated %f,%f",centerCoordinate.latitude, centerCoordinate.longitude);
    self.loc = [[CLLocation alloc]initWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
    [self reloadSearch];
}

- (void)reloadSearch{
    NSLog(@"2--location:{lat:%f; lon:%f}", self.loc.coordinate.latitude, self.loc.coordinate.longitude);
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location                    = [AMapGeoPoint locationWithLatitude:self.loc.coordinate.latitude longitude:self.loc.coordinate.longitude];
    request.sortrule                    = 0;
    request.requireExtension            = YES;
    request.types                       = @"风景名胜|商务住宅|政府机构及社会团体|交通设施服务|公司企业";
    
    [self.search AMapPOIAroundSearch:request];
    
}

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        /*
         CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
         //添加一根针
         ReGeocodeAnnotation *reGeocodeAnnotation = [[ReGeocodeAnnotation alloc] initWithCoordinate:coordinate
         reGeocode:response.regeocode];
         
         NSLog(@"--%@",response.regeocode);
         NSString *str1 = response.regeocode.addressComponent.city;
         if (str1.length == 0) {
         str1 = response.regeocode.addressComponent.province;
         }
         self.mapView.userLocation.title = str1;
         self.mapView.userLocation.subtitle = response.regeocode.formattedAddress;
         [self.mapView addAnnotation:reGeocodeAnnotation];//要添加标注
         [self.mapView selectAnnotation:reGeocodeAnnotation animated:YES];//标注是否有动画效果
         */
    }
}


// 大头针样式
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[ReGeocodeAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"SearchAdressAnnotationView";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        
        // 添加点到数值中,便于改变时移除
        //        if (!_annotationsArray) {
        //            _annotationsArray = [NSMutableArray array];
        //        }
        //        [_annotationsArray addObject:annotation];
        //        _annotation = annotation;
        
        return annotationView;
    }
    return nil;
}

//接收位置更新,实现AMapLocationManagerDelegate代理的amapLocationManager:didUpdateLocation方法，处理位置更新

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
//    self.loc = location;
//    [self hehe];
//    [self.locationManager stopUpdatingLocation];
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0)
    {
        return;
    }
    [self.datas removeAllObjects];
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        MapInfo *info = [[MapInfo alloc]init];
        info.name = obj.name;
        info.address = obj.address;
        info.longitude = obj.location.longitude;
        info.latitude = obj.location.latitude;
        [self.datas addObject:info];
        
    }];
    //解析response获取POI信息，具体解析见 Demo
}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState fromOldState:(MAAnnotationViewDragState)oldState
{
    if (newState == MAAnnotationViewDragStateEnding)
    {
        NSLog(@"我被拖动了");
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    MapInfo *info = [self.datas objectAtIndex:indexPath.row];
    cell.textLabel.text = info.name;
    cell.detailTextLabel.text = info.address;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}


@end
