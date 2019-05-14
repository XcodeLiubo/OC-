//
//  ViewController.m
//  MapKit
//
//  Created by 刘泊 on 2019/4/27.
//  Copyright © 2019 LB. All rights reserved.
//

#import "ViewController.h"

#import <MapKit/MapKit.h>

#include <Aspects.h>


#define JudgeLocalServiceOpen_(_state_) ((_state_) == kCLAuthorizationStatusAuthorizedWhenInUse || (_state_) == kCLAuthorizationStatusAuthorizedAlways)

#define JudgeLocalServiceOpen() JudgeLocalServiceOpen_(([CLLocationManager authorizationStatus]))





#define TestCoordinateLatitude (30.31854274)
#define TestCoordinateLongitude (120.10020478)
#define TestLocalCoordinate ((CLLocationCoordinate2D){TestCoordinateLatitude,TestCoordinateLongitude})


#define LocalCoordinateInput(_latitudeOffset_,_longitudeOffset_) ((CLLocationCoordinate2D){TestCoordinateLatitude + _latitudeOffset_,TestCoordinateLongitude + _longitudeOffset_})


@interface MViewModel : NSObject<MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong, nullable) NSString *address;
@property (nonatomic, strong, nullable) NSString *info;
@end

@implementation MViewModel
+ (instancetype)ViewModelWith:(NSString *)address info:(NSString *)info coordinate:(CLLocationCoordinate2D)coordinate{
    MViewModel* view = [self new];
    view.address = address;
    view.info = info;
    view.coordinate = coordinate;

    return  view;
}


- (NSString *)title{
    return _address;
}

- (NSString *)subtitle{
    return _info;
}

@end
@interface ViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>
@property (nonatomic,weak) IBOutlet MKMapView* map;
@property (nonatomic,strong) CLLocationManager* localMgr;

@property (nonatomic,strong) CLGeocoder* geo;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


//        [self testMapBasic];


    [self testTrackingUserLocal];



    //[self testNavigation];

//    [self aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^void(id obj, bool animation){
//        NSLog(@"%s",__func__);
//    } error:nil];

}



#pragma mark - mapview的基本用法
- (void)testMapBasic{

    /** 地图展现样式
     MKMapTypeStandard = 0,  普通地图
     MKMapTypeSatellite,     卫星地图
     MKMapTypeHybrid,        混合地图(普通覆盖在卫星图上)
     MKMapTypeSatelliteFlyover NS_ENUM_AVAILABLE(10_11, 9_0), ios9 之后才有 3d立体卫星
     MKMapTypeHybridFlyover NS_ENUM_AVAILABLE(10_11, 9_0),    ios9 之后 3d 立体混合
     MKMapTypeMutedStandard ios 11后
     */


    if (@available(iOS 11.0, *)) {
        self.map.mapType = MKMapTypeStandard;
    } else {
        if (@available(iOS 9.0, *)) {
            //            self.map.mapType = MKMapTypeHybridFlyover;
            self.map.mapType = MKMapTypeStandard;
        } else {
            self.map.mapType = MKMapTypeStandard;
        }
    }





    /**
     地图打开后,以哪个经纬度显示在屏幕上的中心点, 这里测试给出一个地址的经纬度坐标
     默认出现在手机屏幕的视区不是 这个被指定的经纬度坐标放大的视图
     比如看到的是整个中国的地图, 但是当前屏幕中心点是以指定的经纬度坐标

     可以指定区域显示

     */
    //    self.map.centerCoordinate = TestLocalCoordinate;
    self.map.centerCoordinate = LocalCoordinateInput(20, 5);





    /** 设置显示区域
     region 里标明了 要显示的中心点 经纬度 和以这个经纬度 往外扩散的地图区域span

     span的值代表 纬度跨度和 经度跨度

     纬度跨度计算比较容易, 在地图上1个纬度的跨度大概是 111km
     经度跨度比较复杂点, 从赤道开始 1个经度跨大概从111km, 往两极靠近的时候, 1个经度的跨度的距离不断减小
     这里可以通过mapview的代理方法 mapView:regionDidChangeAnimated: 里可以取到默认的

     这里测试的数据
     就是指定了 以30.31854274纬度往上下扩展 0.001纬度跨度, 大概是 111km * 0.001的南北范围
     以120.10020478的经度 往东西扩展了 0.001的经度跨度 具体东西范围的计算去看地理, sdk内部会自动处理

     如果需求要求 以指定经纬度为屏幕中心, 然后显示范围是多少米, 要去自己计算

     ps:如果先设置了center属性, 这里在设置region, 则mapview的cengter就是 region设置后的值
     如果先设置了region, 再设置center, 则region的center属性也被改变了, 地国就会以新的经纬度展示在视图里


     */
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    self.map.region = MKCoordinateRegionMake(TestLocalCoordinate, span);





    /** 地图控制属性
     ios 12不显示比例尺
     指南针 模拟器和真机都不显示
     */
    if (@available(iOS 9.0, *)) {
        self.map.showsCompass = true;   ///是否显示指南针
        self.map.showsScale = true;     ///是否显示比例尺 不知道哪里显示的, 应该是在做导航的时候有用
        self.map.showsTraffic = false;  ///是否显示交通 MKMapTypeStandard MKMapTypeHybrid


    } else {
        self.map.showsPointsOfInterest = true; ///MKMapTypeStandard MKMapTypeHybrid
        self.map.showsBuildings = true; ///是否显示建筑 MKMapTypeStandard
        self.map.zoomEnabled = true;
        self.map.scrollEnabled = true;
        self.map.rotateEnabled = true;
        self.map.pitchEnabled = true;
    }



    /**

     显示用户位置 plist
     必须设置 Privacy - Location When In Use Usage Description
     应用的定位授权要打开
     可以不用cl框架去代码开启定位服务 这样的效果是 用户的位改了, 也会更新
     */
    self.map.showsUserLocation = true;




}




#pragma mark - 测试用户跟踪
- (void)testTrackingUserLocal{
    if([self openService]){
        ///如果服务打开就开始定位
        [_localMgr startUpdatingLocation];

        [self trackingUserLocal];
    }

}


#pragma mark - 跟踪用户的位置
- (void)trackingUserLocal{

    if (@available(iOS 9.0, *)) {
        self.map.mapType = MKMapTypeStandard;
    } else {
        self.map.mapType = MKMapTypeStandard;
    }




    CLLocationCoordinate2D center = TestLocalCoordinate;

    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    self.map.region = MKCoordinateRegionMake(center, span);


    /**
     地图跟踪样式
     MKUserTrackingModeNone = 0, 不显示用户位置
     MKUserTrackingModeFollow, 显示用户位置
     MKUserTrackingModeFollowWithHeading 显示位置,并且地图随设备移动方向旋转

     */
    self.map.userTrackingMode = MKUserTrackingModeFollow;




    ////是否显示用户位置 如果设置了这个属性, 即使上面开通了跟踪模式, 也不会显示
//        _map.showsUserLocation = false;

}


#pragma mark - 导航的测试
- (void)testNavigation{
    /**
     核心类
     MKMapItem 一般用作导航的时候, 2个地点之间的绘制路线等信息(方向, 长度等等)
     */


    __weak typeof(self) weakSelf = self;

    [self.geo geocodeAddressString:@"浙江省杭州市" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = self;


        CLPlacemark* beginClp = placemarks.firstObject;

        MKPlacemark* beginP = [[MKPlacemark alloc] initWithPlacemark:beginClp];
        MKMapItem* beginItem = [[MKMapItem alloc] initWithPlacemark:beginP];

        [strongSelf.geo geocodeAddressString:@"上海市" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            CLPlacemark* endClp = placemarks.firstObject;

            MKPlacemark* endP = [[MKPlacemark alloc] initWithPlacemark:endClp];
            MKMapItem* endItem = [[MKMapItem alloc] initWithPlacemark:endP];


            NSDictionary* dic = @{
                                  MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                  MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard),
                                  MKLaunchOptionsShowsTrafficKey:@1
                                  };
            [MKMapItem openMapsWithItems:@[beginItem,endItem] launchOptions:dic];
        }];

    }];

}

#pragma mark - 地图快照
- (void)testMapSnap{

    MKMapSnapshotOptions* options = [[MKMapSnapshotOptions alloc] init];
    options.mapType = _map.mapType;
    options.region = _map.region;
    options.size = CGSizeMake(500, 600);
    options.scale = UIScreen.mainScreen.scale;
    MKMapSnapshotter* snap = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snap startWithCompletionHandler:^(MKMapSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (!error) {
            UIImage* img = snapshot.image;
            NSLog(@"%lud",UIImagePNGRepresentation(img).length);
        }
    }];
}



#pragma mark - 3d视角
- (void)test3D{
    if (@available(iOS 9.0, *)) {
        //        MKMapCamera* camera = [MKMapCamera cameraLookingAtCenterCoordinate:TestLocalCoordinate fromDistance:(1000) pitch:20 heading:270];
        //
        //        [self.map setCamera:camera animated:1];

        MKMapCamera* camera = [MKMapCamera cameraLookingAtCenterCoordinate:TestLocalCoordinate fromEyeCoordinate:LocalCoordinateInput(0.001, 0.001) eyeAltitude:10];

        [self.map setCamera:camera animated:1];
    } else {
        MKMapCamera* camera = [MKMapCamera cameraLookingAtCenterCoordinate:TestLocalCoordinate fromEyeCoordinate:LocalCoordinateInput(0.001, 0.001) eyeAltitude:100];

        [self.map setCamera:camera animated:1];
    }
}


#pragma mark - 绘制导航
- (void)testDisPlayNav{
    __weak typeof(self) weakSelf = self;
    [self.geo geocodeAddressString:@"杭州" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        CLPlacemark* beginClp = placemarks.firstObject;

        /**
         可以在当前经纬度上添加一个覆盖层, 添加覆盖层的概念和大头针的概念是一样的
         先添加数据模型, 然后调用 mapView的 addOverLay:
         之后在对应的代理 mapView:rendererForOverlay:作处理
         */

        MKCircle* beginCircle = [MKCircle circleWithCenterCoordinate:beginClp.location.coordinate radius:(100000)];

        [strongSelf.map addOverlay:beginCircle];



        [strongSelf.geo geocodeAddressString:@"乌鲁木齐" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            CLPlacemark* endClp = placemarks.firstObject;

            /**
             可以在当前经纬度上添加一个覆盖层, 添加覆盖层的概念和大头针的概念是一样的
             先添加数据模型, 然后调用 mapView的 addOverLay:
             之后在对应的代理 mapView:rendererForOverlay:作处理
             */

            MKCircle* endCircle = [MKCircle circleWithCenterCoordinate:endClp.location.coordinate radius:(100000)];

            [strongSelf.map addOverlay:endCircle];


            [strongSelf disPlahyFrom:beginClp to:endClp];
        }];
    }];
}


#pragma mark - 根据地标 去向服务器那导航数据(苹果)
- (void)disPlahyFrom:(CLPlacemark*)beginClp to:(CLPlacemark*)endClp{
    ///创建请求对象
    MKDirectionsRequest* request = [MKDirectionsRequest new];

    request.source = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:beginClp]];
    request.destination = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:endClp]];



    ///创建导航对象
    MKDirections* result = [[MKDirections alloc] initWithRequest:request];

    [result calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        [response.routes enumerateObjectsUsingBlock:^(MKRoute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            // 添加覆盖层数据模型,路线对应的几何线路模型（由很多点组成）
            // 当我们添加一个覆盖层数据模型时, 系统绘自动查找对应的代理方法, 找到对应的覆盖层"视图"
            [self.map addOverlay:obj.polyline];  // 添加折线

            // block 遍历每一种路线的每一个步骤（MKRouteStep对象）
            //            [obj.steps enumerateObjectsUsingBlock:^(MKRouteStep * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //                NSLog(@"%@",obj.instructions);
            //            }];
        }];
    }];

}



- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    [mapView removeOverlays:mapView.overlays];

    ///这里没有复用的机制
    if ([overlay isKindOfClass:MKCircle.class]) {
        MKCircleRenderer* render = [[MKCircleRenderer alloc] initWithCircle:overlay];
        render.fillColor = UIColor.redColor;
        render.lineWidth = 5;
        render.alpha = 0.5;
        return render;
    }


    if ([overlay isKindOfClass:MKPolyline.class]) {
        MKPolylineRenderer* line = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        line.strokeColor = UIColor.blueColor;
        line.lineJoin = kCGLineJoinRound;
        line.lineWidth = 4;
        return line;
    }


    return nil;
}





#pragma mark - map定位到用户的位置的时候的时候来这里, 开启用户跟踪
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{

    /**
     这里去查询的时候,是异步的, 但是内部回调回来之后, 大头针的视图还是会自动更新
     */
    [self.geo reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error)return;
        /**
         pl.country 国家:中国
         pl.administrativeArea 省:浙江省
         pl.locality 城市:杭州
         pl.subLocality 区:拱墅区
         pl.thoroughfare 街道:学院北路什么的
         pl.subThoroughfare 街道的具体地址
         pl.pl.ISOcountryCode 国家编码:CN
         pl.postalCode 邮编

         以上有可能是空
         */
        CLPlacemark* pl = placemarks.firstObject;
        userLocation.title = [NSString stringWithFormat:@"%@%@%@",pl.country,pl.administrativeArea,pl.locality];
        userLocation.subtitle = [NSString stringWithFormat:@"%@%@",pl.subLocality,pl.thoroughfare];

        //        [mapView reloadInputViews];
    }];

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{

    /////这里复用的思想是 和cell一样
#if 0

    ////这里是模拟用户跟踪的时候 改变闪烁的大头针的视图样式 ios12 系统创建的是MKModernUserLocationView

    MKAnnotationView* annoView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"sys"];
    if (!annoView) {
        annoView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"sys"];
        annoView.leftCalloutAccessoryView = [UIImageView new];
    }

    annoView.annotation = annotation;

    ((UIImageView*)(annoView.leftCalloutAccessoryView)).image = [UIImage imageNamed:@"user_jiekuan_sh_ing"];

    ///大头针的显示图片
    annoView.image = [UIImage imageNamed:@"top_nav_back"];

    annoView.canShowCallout = 1;


    ///如果当前返回nil 系统会自己创建
    return annoView;

#elif 0

    ////这里是模拟 点击屏幕添加视图的时候 添加大头针数据模型后 系统的默认做法 ios12系统创建的是MKMarkerAnnotationView
    MKPinAnnotationView* view = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];

        view.animatesDrop = true;  ///当添加大头针的时候, 从天而降

        view.canShowCallout = true; ///开启关联视图


        view.leftCalloutAccessoryView = [UIImageView new];
    }

    if (@available(iOS 9.0, *)) {
        ///设置系统大头针图标的颜色
        view.pinTintColor = UIColor.blackColor;

        ////类方法设置 好像没什么卵用
        //        [MKPinAnnotationView redPinColor];
        //        [MKPinAnnotationView purplePinColor];
        //        [MKPinAnnotationView greenPinColor];

    } else {
        view.pinColor = MKPinAnnotationColorGreen;
    }



    view.annotation = annotation;


    ///因为是系统的, 不管改变本身的图标 .image 还是关联视图, 都没有效果
    ((UIImageView*)view.leftCalloutAccessoryView).image = [UIImage imageNamed:@"user_jiekuan_sh_ing"];


    return view;


#elif 1

    ////做法就是模拟用户跟踪的时候系统的做法
    MKAnnotationView* view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"sys"];
    if (nil == view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"sys"];
        view.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_jiekuan_sh_ing"]];

        view.draggable = 1;
        view.canShowCallout = 1;
    }

    view.image = [UIImage imageNamed:@"user_jiekuan_sh_ing"];

    view.annotation = annotation;

    return view;
#endif

}


#pragma mark - map区域发生改变的时候来这里(拖动地图)
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    NSLog(@"%@",view);
}






- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    ///大头针
    //    [self testInputAnnotateWithTouch:touches.anyObject];


    ///导航测试
    //    [self testNavigation];


    ///地图快照
    //    [self testMapSnap];


    ////3d视角
    //    [self test3D];



    ////绘制导航
    [self testDisPlayNav];
}


#pragma mark - 手指点击屏幕创建大头针的测试
- (void)testInputAnnotateWithTouch:(UITouch*)touch{

    CGPoint p = [touch locationInView:self.view];
    p = [self.view convertPoint:p toView:self.map];
    CLLocationCoordinate2D coordinate = [self.map convertPoint:p toCoordinateFromView:self.map];


    __weak typeof(self) weakSelf = self;
    CLLocation* loca = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self.geo reverseGeocodeLocation:loca completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        __strong typeof(weakSelf) sSelf = weakSelf;

        CLPlacemark* pl = placemarks.firstObject;
        NSString* title = [NSString stringWithFormat:@"%@%@%@",pl.country,pl.administrativeArea,pl.locality];
        NSString* subtitle = [NSString stringWithFormat:@"%@%@",pl.subLocality,pl.thoroughfare];
        [sSelf.map addAnnotation:[MViewModel ViewModelWith:title info:subtitle coordinate:coordinate]];
    }];

}








#pragma mark - 打开定位服务
- (bool)openService{
    ////必须要开启定位才能使用地图跟踪模式
    if (!_localMgr){
        _localMgr = [CLLocationManager new];
        _localMgr.delegate = self;
    }



    ///ios8之前只是在info.plist里添加描述字段就可以了
    if (@available(iOS 8, *)) {
        goto _iOS8Judge;
    }else return false;


_iOS8Judge:

    if (!JudgeLocalServiceOpen() ) { ///判断定位授权状态很耗时, 而且阻塞主线程
        NSLog(@"%d",[CLLocationManager authorizationStatus]);
        NSLog(@"用户没有授权定位");
        return false;
    }

    ////申请前台定位
    [_localMgr requestWhenInUseAuthorization];

    return true;

}



#pragma mark - 关闭定位
- (void)closeLocalService:(CLLocationManager*)mgr{
    [mgr stopUpdatingLocation];
}





#pragma mark - 用户的授权状态放生变化的时候
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (!JudgeLocalServiceOpen_(status)) {
        [self closeLocalService:manager];
    }else{
        [self closeLocalService:manager];
        if (_localMgr == manager && [self openService]) {
            [manager startUpdatingLocation];
            [self trackingUserLocal];
        }
    }
}


#pragma mark - cl定位的时候来这里
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{

}


- (CLGeocoder *)geo{
    if (!_geo) {
        _geo = [CLGeocoder new];
    }
    return _geo;
}

@end
