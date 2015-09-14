//
//  MRHomeViewController.m
//  ParkingWe
//
//  Created by 李白 on 15-7-30.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

#import "MRHomeViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import "MRPaoPaoView.h"
#import "MRRouteAnnotation.h"
#import "UIImage+Rotate.h"
#import "MRPointAnnotation.h"
#import "MRParkDetailTableViewController.h"
#import "MBProgressHUD+MR.h"


@interface MRHomeViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate, BMKPoiSearchDelegate,BMKGeoCodeSearchDelegate, BMKRouteSearchDelegate,MRParkDetailTableViewControllerDelegate>

/**
 *  百度地图view
 */
@property(nonatomic,strong)BMKMapView *mapView;
/**
 *  定位服务
 */
@property(nonatomic,strong)BMKLocationService *locationService;
/**
 *  地理编码
 */
@property(nonatomic,strong)BMKGeoCodeSearch *geocodeSearch;
/**
 *  POI检索
 */
@property(nonatomic,strong)BMKPoiSearch *poiSearch;

/**
 *  用于保存POI检索返回的所有结果
 */
@property(nonatomic,strong)NSMutableArray *resultsArray;

/**
 *  记录点击的标注对应的poiUid
 */
@property(nonatomic,copy)NSString *poiUid;


/**
 *  用于记录当前用户所在的位置信息
 */
@property(nonatomic,strong)BMKUserLocation *userLocation;


@property(nonatomic,strong)MRPaoPaoView *paopaoView;

@property(nonatomic,strong)BMKActionPaopaoView *actionPaopaoView;

///**
// *  用于记录当前用户的所在地址
// */
//@property(nonatomic,copy)NSString *currentAddress;


/**
 *  到这里去按钮
 */
@property(nonatomic,strong)UIButton *gotoBtn;

/**
 *  详情按钮
 */
@property(nonatomic,strong)UIButton *detailBtn;


/**
 *  记录目的地的坐标
 */
@property(nonatomic,assign)CLLocationCoordinate2D gotoCoordinate;
///**
// *  记录目的地的地址
// */
//@property(nonatomic,copy)NSString *gotoAddress;

/**
 *  route搜索服务
 */
@property(nonatomic,strong)BMKRouteSearch *routeSearch;


@end



@implementation MRHomeViewController 

- (NSString*)getMyBundlePath1:(NSString *)filename
{
    
    NSBundle * libBundle = MYBUNDLE ;
    if ( libBundle && filename ){
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        return s;
    }
    return nil ;
}


#pragma mark - 懒加载
- (BMKMapView *)mapView
{
    if (_mapView == nil) {
        _mapView = [[BMKMapView alloc] init];
    }
    return _mapView;
}

- (BMKLocationService *)locationService
{
    if (_locationService == nil) {
        _locationService = [[BMKLocationService alloc] init];
    }
    return _locationService;
}

- (BMKGeoCodeSearch *)geocodeSearch
{
    if (_geocodeSearch == nil) {
        _geocodeSearch = [[BMKGeoCodeSearch alloc] init];
    }
    return _geocodeSearch;
}

- (BMKPoiSearch *)poiSearch
{
    if (_poiSearch == nil) {
        _poiSearch = [[BMKPoiSearch alloc] init];
    }
    return _poiSearch;
}

- (MRPaoPaoView *)paopaoView
{
    if (_paopaoView == nil) {
        _paopaoView = [[[NSBundle mainBundle] loadNibNamed:@"MRPaoPaoView" owner:nil options:nil] lastObject];
    }
    return _paopaoView;
}

- (BMKActionPaopaoView *)actionPaopaoView
{
    if (_actionPaopaoView == nil) {
        
        _actionPaopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:self.paopaoView];
        _actionPaopaoView.backgroundColor = [UIColor greenColor];
    }
    return _actionPaopaoView;
}

- (UIButton *)gotoBtn
{
    if (_gotoBtn == nil) {
        _gotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _gotoBtn.bounds = CGRectMake(0, 0, 48, 48);
        [_gotoBtn setBackgroundImage:[UIImage imageNamed:@"btn_goto"] forState:UIControlStateNormal];
        
        [_gotoBtn addTarget:self
                    action:@selector(gotoBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _gotoBtn;
}

#pragma mark - 懒加载
- (UIButton *)detailBtn
{
    if (_detailBtn == nil) {
        _detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _detailBtn.bounds = CGRectMake(0, 0, 48, 48);
        [_detailBtn setBackgroundImage:[UIImage imageNamed:@"btn_detail"] forState:UIControlStateNormal];
        
        [_detailBtn addTarget:self action:@selector(detailBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _detailBtn;
}



#pragma mark - 懒加载
- (BMKRouteSearch *)routeSearch
{
    if (_routeSearch == nil) {
        _routeSearch = [[BMKRouteSearch alloc] init];
    }
    return _routeSearch;
}




#pragma mark -
#pragma mark 系统方法

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 添加地图view到控制器的view中
    [self.view addSubview:self.mapView];

    Mylog(@"%@", NSStringFromCGRect(self.view.frame));
    
    // 给mapView设置约束
    __weak typeof(self) weakSelf = self;
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    
//    Mylog(@"%@", NSStringFromCGRect(self.mapView.frame));
//    
//    Mylog(@"%@", self.mapView.constraints);

    // 添加按钮
    [self addBtn];
    
}

- (void)addBtn
{
    UIButton *meBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [meBtn setImage:[UIImage imageNamed:@"order_detail_weizhi_icon"] forState:UIControlStateNormal];
    [meBtn setBackgroundImage:[UIImage imageNamed:@"icon_compass_background"] forState:UIControlStateNormal];
    [meBtn addTarget:self action:@selector(meBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    meBtn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:meBtn];
    
    UIButton *locBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [locBtn setImage:[UIImage imageNamed:@"walk_turn_35"] forState:UIControlStateNormal];
    [locBtn setBackgroundImage:[UIImage imageNamed:@"icon_compass_background"] forState:UIControlStateNormal];
    [locBtn addTarget:self action:@selector(locBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    locBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:locBtn];
    
    [meBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.bottom.equalTo(self.view).offset(-40);
        make.width.equalTo(@35);
        make.height.equalTo(@35);
    }];


    
    [locBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
//        make.bottom.equalTo(self.view.bottom).offset(20);
        make.width.equalTo(@35);
        make.height.equalTo(@35);
        make.bottom.equalTo(meBtn.mas_top).offset(-10);
    }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupMapView];
}


/**
 *  地图的各种服务的初始化
 */
- (void)setupMapView
{

    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    // 禁止地图旋转
    self.mapView.rotateEnabled = NO;
    
    BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
    param.locationViewOffsetX = 0;
    param.locationViewOffsetY = 0;
    param.isAccuracyCircleShow = NO;
    param.locationViewImgName = @"bnavi_icon_location_fixed";
    [self.mapView updateLocationViewWithParam:param];
    
    
    //    // 设置定位精确度
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    // 指定定位的最小更新距离(米)，默认：kCLDistanceFilterNone
    [BMKLocationService setLocationDistanceFilter:100.0f];
    
    // 设置定位服务的代理
    self.locationService.delegate = self;
    // 开始定位
    [self.locationService startUserLocationService];
    //    self.mapView.showsUserLocation = NO;//先关闭显示的定位图层
    self.mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;//设置定位的状态
    self.mapView.showsUserLocation = YES;//显示定位图层
    
    // 设置POI检索的代理
    self.poiSearch.delegate = self;
    
    self.geocodeSearch.delegate = self;
    
    self.routeSearch.delegate = self;

}



/*
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    Mylog(@"%@", self.view.subviews);
    
//    Mylog(@"%f, %f", [BMKLocationService getCurrentLocationDesiredAccuracy], [BMKLocationService getCurrentLocationDistanceFilter]);
//    Mylog(@"%f", self.mapView.zoomLevel);
 
//    Mylog(@"%@", NSStringFromCGRect(self.view.frame));
//    Mylog(@"%@", NSStringFromCGRect(self.mapView.frame));
//    
//    Mylog(@"%@", self.mapView.constraints);
}
*/

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    Mylog(@"view即将消失");
    
//    [self clearServiceFromMapView];

}

/**
 *  清空地图的各种服务
 */
- (void)clearServiceFromMapView
{
    self.mapView.delegate = nil; // 不用时，置nil
    self.locationService = nil;
    self.geocodeSearch.delegate = nil;
    self.routeSearch.delegate = nil;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    Mylog(@"----");
    
    self.mapView = nil;
}

#pragma mark - 
#pragma mark  控制器内部方法
#pragma mark -
- (void)meBtnClick:(UIButton *)meBtn
{
    Mylog(@"meBtn");

    [self clearOverlay];
    
    [self showUserLocation:self.userLocation];
    
}
- (void)locBtnClick:(UIButton *)locBtn
{
    Mylog(@"locBtn");
    
    [self clearOverlay];
    
    Mylog(@"%f, %f", self.userLocation.location.coordinate.latitude, self.userLocation.location.coordinate.longitude);
    Mylog(@"%f, %f", self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude);
    
    [self searchWithLocation:self.mapView.centerCoordinate radius:5000 keyword:@"停车场"];
}



#pragma mark -
#pragma mark BMKMapViewDelegate

/**10
 *地图初始化完毕时会调用此接口
 *@param mapview 地图View
 */
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    Mylog(@"成功载入地图后调用");
    
    // 设置指南针在地图左上角
    self.mapView.compassPosition = CGPointMake(10, 100);
}

/**
 *地图渲染每一帧画面过程中，以及每次需要重绘地图时（例如添加覆盖物）都会调用此接口
 *@param mapview 地图View
 *@param status 此时地图的状态
 */
//- (void)mapView:(BMKMapView *)mapView onDrawMapFrame:(BMKMapStatus*)status
//{
//    Mylog(@"---");
//}

/**
 *地图区域即将改变时会调用此接口
 *@param mapview 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    Mylog(@"地图区域即将改变时会调用此接口");
}

/**
 *地图区域改变完成后会调用此接口
 *@param mapview 地图View
 *@param animated 是否动画
 */

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    Mylog(@"地图区域改变完成后会调用此接口");
}
/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    Mylog(@"根据anntation生成对应的Viewv");
    
//    if (![annotation isKindOfClass:[MRPointAnnotation class]]) {
//        // 处理系统自带的我的位置的大头针
//        return nil;
//    }

    if ([annotation isKindOfClass:[MRRouteAnnotation class]]) {
        return [self getRouteAnnotationView:self.mapView viewForAnnotation:(MRRouteAnnotation*)annotation];
    }
    
    
    if ([annotation isKindOfClass:[MRPointAnnotation class]]) {
        
        static NSString *annoIdentifier = @"park";
        
        BMKPinAnnotationView *parkPointView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annoIdentifier];
        
        if (parkPointView == nil) {
            parkPointView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annoIdentifier];
            
            //        parkPointView.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:[UIButton buttonWithType:UIButtonTypeContactAdd]];
            
            parkPointView.image = [UIImage imageNamed:@"an_3_P"];
            
            parkPointView.leftCalloutAccessoryView = self.gotoBtn;
            parkPointView.rightCalloutAccessoryView = self.detailBtn;
            // 设置颜色
            //        parkPointView.pinColor = BMKPinAnnotationColorPurple;
            // 从天上掉下效果
            parkPointView.animatesDrop = YES;
            // 设置可拖拽
            parkPointView.draggable = YES;
            
        }
        
        return parkPointView;
    }
    
    return nil;
}

/**
 *当mapView新添加annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 新添加的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    Mylog(@"当mapView新添加annotation views时，调用此接口");
}
/**
 *当选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    Mylog(@"当选中一个annotation views时，调用此接口");
    
//    view.paopaoView = self.paopaoView;
    
//    Mylog(@"%@", NSStringFromCGRect(view.paopaoView.frame));
    
    // 获取点击的view的annotation
    MRPointAnnotation *anno = view.annotation;
    
//    MRRouteAnnotation *anno = view.annotation;
    
    // 保存点击的标注的坐标
    self.gotoCoordinate = anno.coordinate;
    
    // 保存点击的标注对应的poiUid
    self.poiUid = anno.poiUid;
    
    // 反地理编码 获取用户目的地地址
    BMKReverseGeoCodeOption *reverse = [[BMKReverseGeoCodeOption alloc] init];
    reverse.reverseGeoPoint = anno.coordinate;
    [self.geocodeSearch reverseGeoCode:reverse];
    
    
    
}
/**
 *当取消选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 取消选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view
{
    Mylog(@"当取消选中一个annotation views时，调用此接口");
    
    
}
/**
 *拖动annotation view时，若view的状态发生变化，会调用此函数。ios3.2以后支持
 *@param mapView 地图View
 *@param view annotation view
 *@param newState 新状态
 *@param oldState 旧状态
 */
- (void)mapView:(BMKMapView *)mapView annotationView:(BMKAnnotationView *)view didChangeDragState:(BMKAnnotationViewDragState)newState
   fromOldState:(BMKAnnotationViewDragState)oldState
{
    Mylog(@"拖动annotation view时，若view的状态发生变化，会调用此函数");
}


/**
 *根据overlay生成对应的View
 *@param mapView 地图View
 *@param overlay 指定的overlay
 *@return 生成的覆盖物View
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    Mylog(@"根据overlay生成对应的View");
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    return nil;
}

/**
 *当mapView新添加overlay views时，调用此接口
 *@param mapView 地图View
 *@param overlayViews 新添加的overlay views
 */
- (void)mapView:(BMKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews
{
    Mylog(@"当mapView新添加overlay views时，调用");
}
/**
 *点中覆盖物后会回调此接口，目前只支持点中BMKPolylineView时回调
 *@param mapview 地图View
 *@param overlayView 覆盖物view信息
 */
- (void)mapView:(BMKMapView *)mapView onClickedBMKOverlayView:(BMKOverlayView *)overlayView
{
    Mylog(@"点中覆盖物");
}
/**
 *点中底图标注后会回调此接口
 *@param mapview 地图View
 *@param mapPoi 标注点信息
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi*)mapPoi
{
    Mylog(@"点中底图标注");
}
/**
 *点中底图空白处会回调此接口
 *@param mapview 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    Mylog(@"点中底图空白处");
}




#pragma mark -
#pragma mark BMKLocationServiceDelegate
/**
 *在将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser
{
    Mylog(@"开始定位");
}
/**
 *在停止定位后，会调用此函数
 */
- (void)didStopLocatingUser
{
    Mylog(@"停止定位");
}
/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    Mylog(@"方向更新--%@", userLocation);
}
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    Mylog(@"用户位置更新后，会调用此函数");
//    Mylog(@"位置更新--%f, %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
//    Mylog(@"位置更新--%f, %f", self.locationService.userLocation.location.coordinate.latitude, self.locationService.userLocation.location.coordinate.longitude);
    
    if (userLocation.location) {
        
        // 保存用户位置信息
        self.userLocation = userLocation;
        
        [self showUserLocation:userLocation];
        
    }
    
}
/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    Mylog(@"定位失败后，会调用此函数---%@", error);
}




#pragma mark -
#pragma mark BMKPoiSearchDelegate
/**
 *返回POI搜索结果
 *@param searcher 搜索对象
 *@param poiResult 搜索结果列表
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
    Mylog(@"返回POI搜索结果");
    
    /*
     BMK_SEARCH_NO_ERROR =0,///<检索结果正常返回
     BMK_SEARCH_AMBIGUOUS_KEYWORD,///<检索词有岐义
     BMK_SEARCH_AMBIGUOUS_ROURE_ADDR,///<检索地址有岐义
     BMK_SEARCH_NOT_SUPPORT_BUS,///<该城市不支持公交搜索
     BMK_SEARCH_NOT_SUPPORT_BUS_2CITY,///<不支持跨城市公交
     BMK_SEARCH_RESULT_NOT_FOUND,///<没有找到检索结果
     BMK_SEARCH_ST_EN_TOO_NEAR,///<起终点太近
     BMK_SEARCH_KEY_ERROR,///<key错误
     BMK_SEARCH_NETWOKR_ERROR,///网络连接超时
     BMK_SEARCH_NETWOKR_TIMEOUT,///网络连接超时
     BMK_SEARCH_PERMISSION_UNFINISHED,///还未完成鉴权，请在鉴权通过后重试
     
     */
    
    switch (errorCode) {
        case BMK_SEARCH_NO_ERROR:
            Mylog(@"检索结果正常返回");{
                
                self.resultsArray = [NSMutableArray array];
                
                Mylog(@"%zd, %zd", poiResult.pageNum, poiResult.totalPoiNum);
                
                if (poiResult.pageIndex < (poiResult.pageNum - 1)) {
                    poiResult.pageIndex += 1;
                    [self.resultsArray addObjectsFromArray:poiResult.poiInfoList];
                }
                
                Mylog(@"%zd", self.resultsArray.count);
//                Mylog(@"%zd", poiResult.pageIndex);
//                NSArray *poiInfoList = poiResult.poiInfoList;
                [self showAll:self.resultsArray];
            }
            break;
        case BMK_SEARCH_AMBIGUOUS_KEYWORD:
            Mylog(@"检索词有岐义");
            break;
        case BMK_SEARCH_AMBIGUOUS_ROURE_ADDR:
            Mylog(@"检索地址有岐义");
            break;
        case BMK_SEARCH_NOT_SUPPORT_BUS:
            Mylog(@"该城市不支持公交搜索");
            break;
        case BMK_SEARCH_NOT_SUPPORT_BUS_2CITY:
            Mylog(@"不支持跨城市公交");
            break;
        case BMK_SEARCH_RESULT_NOT_FOUND:
            Mylog(@"没有找到检索结果");
            break;
        case BMK_SEARCH_ST_EN_TOO_NEAR:
            Mylog(@"起终点太近");
            break;
        case BMK_SEARCH_KEY_ERROR:
            Mylog(@"错误");
            break;
        case BMK_SEARCH_NETWOKR_ERROR:
            Mylog(@"网络连接超时");
            break;
        case BMK_SEARCH_PERMISSION_UNFINISHED:
            Mylog(@"还未完成鉴权，请在鉴权通过后重试");
            break;
        default:
            break;
    }


}

/**
 *返回POI详情搜索结果
 *@param searcher 搜索对象
 *@param poiDetailResult 详情搜索结果
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
- (void)onGetPoiDetailResult:(BMKPoiSearch*)searcher result:(BMKPoiDetailResult*)poiDetailResult errorCode:(BMKSearchErrorCode)errorCode
{
    Mylog(@"返回POI详情搜索结果");
    Mylog(@"%@", [NSThread currentThread]);
    // 正常返回
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        
        [self clearOverlay];
        
//        UIStoryboard *parkDetail = [UIStoryboard storyboardWithName:@"ParkDetail" bundle:nil];
//        
//        [self.navigationController presentViewController:[parkDetail instantiateInitialViewController] animated:nil completion:nil];

        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//        });
        
        
        // 手动执行segue
        [self performSegueWithIdentifier:@"annotation2detail" sender:poiDetailResult];
    
    }
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Mylog(@"执行segue");
    
    Mylog(@"%@",sender);
    
    MRParkDetailTableViewController *detailVc = segue.destinationViewController;
    detailVc.detailResult = (BMKPoiDetailResult *)sender;
    detailVc.delegate = self;
}



/**
 *  城市内检索
 *
 *  @param city
 *  @param keyword
 */
- (void)searchInCity:(NSString *)city keyWord:(NSString *)keyword
{
    BMKCitySearchOption *citySearch = [[BMKCitySearchOption alloc] init];
    // 检索的页码
    citySearch.pageIndex = 0;
    // 检索的条数
    citySearch.pageCapacity = 50;
    citySearch.city = city;
    citySearch.keyword = keyword;
    citySearch.pageIndex = 30;
    citySearch.pageCapacity = 50;
    
    
    BOOL flag = [self.poiSearch poiSearchInCity:citySearch];
    
    if(flag)
    {
        Mylog(@"城市内检索发送成功");
    }
    else
    {
        Mylog(@"城市内检索发送失败");
    }

}
/**
 *  周边检索
 *
 *  @param location
 *  @param radius
 *  @param keyword
 */
- (void)searchWithLocation:(CLLocationCoordinate2D)location radius:(int)radius keyword:(NSString *)keyword
{
    BMKNearbySearchOption *nearbySearch = [[BMKNearbySearchOption alloc] init];
    // 分页索引
    nearbySearch.pageIndex = 0;
    // 分页数量
    nearbySearch.pageCapacity = 50;
    nearbySearch.location = location;
    nearbySearch.radius = radius;
    nearbySearch.keyword = keyword;
    // 搜索结果排序规则
    nearbySearch.sortType = BMK_POI_SORT_BY_DISTANCE;
    
    BOOL flag = [self.poiSearch poiSearchNearBy:nearbySearch];
    
    if(flag)
    {
        Mylog(@"周边检索发送成功");
    }
    else
    {
        Mylog(@"周边检索索发送失败");
    }

}

#pragma mark -
#pragma mark BMKGeoCodeSearchDelegate
/**
 *返回地址信息搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结BMKGeoCodeSearch果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error) {
        Mylog(@"搜索结果错误--%u", error);
        return;
    }
    
    Mylog(@"%@", result.address);
    
}

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error) {
        Mylog(@"搜索结果错误--%u", error);
        return;
    }

    Mylog(@"%@", result.address);
    
    
}

#pragma mark -
#pragma mark BMKRouteSearchDelegate
/**
 *返回驾乘搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果，类型为BMKDrivingRouteResult
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
//    if (error) {
//        Mylog(@"驾乘搜索结果---错误%u", error);
//    }
//    
//    Mylog(@"%@", result.routes);
//
//    // 遍历所有路线
////    for (BMKDrivingRouteLine *routeLine in result.routes) {
////        Mylog(@"%@", routeLine.wayPoints);
////        
////    }
//
//    BMKDrivingRouteLine *routeLine = [result.routes firstObject];
//    
//    Mylog(@"%@", routeLine.steps);
////    
//    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
//    [_mapView removeAnnotations:array];
//    array = [NSArray arrayWithArray:_mapView.overlays];
//    [_mapView removeOverlays:array];
//
    // 清除地图上的标注和覆盖物
    [self clearOverlay];
    
    
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
        NSUInteger size = [plan.steps count];
        NSUInteger planPointCounts = 0;
        for (NSUInteger i = 0; i < size; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                MRRouteAnnotation* item = [[MRRouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = MRRouteAnnotationTypeStart;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }else if(i==size-1){
                MRRouteAnnotation* item = [[MRRouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = MRRouteAnnotationTypeEnd;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            MRRouteAnnotation* item = [[MRRouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = MRRouteAnnotationTypeDrive;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode* tempNode in plan.wayPoints) {
                MRRouteAnnotation* item = [[MRRouteAnnotation alloc]init];
                item = [[MRRouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = MRRouteAnnotationTypeWayPoint;
                item.title = tempNode.name;
                [_mapView addAnnotation:item];
            }
        }
        
        
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        
        
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    
    }
}



#pragma mark -
#pragma mark 其他方法

- (void)showAll:(NSArray *)poiInfoList
{
    Mylog(@"%lu", (unsigned long)poiInfoList.count);
    for (BMKPoiInfo *info in poiInfoList) {
//        Mylog(@"%@--%@--%@--%f--%f", info.name, info.uid, info.address, info.pt.latitude, info.pt.longitude);
        
        MRPointAnnotation *pointAnno = [[MRPointAnnotation alloc] init];
        pointAnno.title = info.name;
        pointAnno.subtitle = info.address;
        pointAnno.coordinate = info.pt;
        pointAnno.poiUid = info.uid;
        [self.mapView addAnnotation:pointAnno];
    }
}


#pragma mark
- (void)showUserLocation:(BMKUserLocation *)userLocation
{
    
    
    //  更新用户位置信息
    [self.mapView updateLocationData:userLocation];
    
    //        // 设置地图显示的区域
    //        // 获取用户的位置
    CLLocationCoordinate2D coordinate = userLocation.location.coordinate;
    // 将用户当前的位置作为显示区域的中心点, 并且指定需要显示的跨度范围
    
    [self.mapView setCenterCoordinate:coordinate animated:YES];
    
    BMKCoordinateSpan span = BMKCoordinateSpanMake(0.5, 0.5);
    
    BMKCoordinateRegion region = BMKCoordinateRegionMake(coordinate, span);
    
    [self.mapView setRegion:region];
    
    [self.mapView regionThatFits:region];
    
    
    // 设置定位到用户位置后地图缩放的等级
    self.mapView.zoomLevel = 16.0;
    
    //        [self searchInCity:@"北京" keyWord:@"停车场"];
    
    [self searchWithLocation:coordinate radius:5000 keyword:@"停车场"];
    
}

/**
 *  清除地图上的标注和覆盖物
 */
- (void)clearOverlay
{
    NSArray *annotations = self.mapView.annotations;
    [self.mapView removeAnnotations:annotations];
    
    NSArray *overlays = self.mapView.overlays;
    [self.mapView removeOverlays:overlays];
    
    // 返回用户当前位置
//    [self showUserLocation:self.userLocation];
}

- (void)gotoBtnClick
{
    Mylog(@"到这里去");
    
    BMKDrivingRoutePlanOption *drivingRoutePlan = [[BMKDrivingRoutePlanOption alloc] init];
    BMKPlanNode *fromNode = [[BMKPlanNode alloc] init];
    fromNode.pt = self.userLocation.location.coordinate;
    drivingRoutePlan.from = fromNode;
    
    BMKPlanNode *toNode = [[BMKPlanNode alloc] init];
    toNode.pt = self.gotoCoordinate;
    drivingRoutePlan.to = toNode;
    
    drivingRoutePlan.drivingPolicy = BMK_DRIVING_TIME_FIRST;
    drivingRoutePlan.drivingRequestTrafficType = BMK_DRIVING_REQUEST_TRAFFICE_TYPE_NONE;
    
    BOOL flag = [self.routeSearch drivingSearch:drivingRoutePlan];
    if(flag)
    {
        NSLog(@"car检索发送成功");
    }
    else
    {
        NSLog(@"car检索发送失败");
    }
}

- (void)detailBtnClick
{
    BMKPoiDetailSearchOption *poiDetailSearchOption = [[BMKPoiDetailSearchOption alloc] init];
    poiDetailSearchOption.poiUid = self.poiUid;
    
    [self.poiSearch poiDetailSearch:poiDetailSearchOption];

}


- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(MRRouteAnnotation*)routeAnnotation
{
    BMKAnnotationView* view = nil;
    switch (routeAnnotation.type) {
        case MRRouteAnnotationTypeStart:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case MRRouteAnnotationTypeEnd:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case MRRouteAnnotationTypeBus:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_bus.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case MRRouteAnnotationTypeSubway:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_rail.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case MRRouteAnnotationTypeDrive:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction.png"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
            
        }
            break;
        case MRRouteAnnotationTypeWayPoint:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"waypoint_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"waypoint_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_waypoint.png"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
        }
            break;
        default:
            break;
    }
    
    return view;
}




//- (void)wayPointDemo {
//    
//    WayPointRouteSearchDemoViewController * wayPointCont = [[WayPointRouteSearchDemoViewController alloc]init];
//    wayPointCont.title = @"驾车途经点";
//    UIBarButtonItem *customLeftBarButtonItem = [[UIBarButtonItem alloc] init];
//    customLeftBarButtonItem.title = @"返回";
//    self.navigationItem.backBarButtonItem = customLeftBarButtonItem;
//    [self.navigationController pushViewController:wayPointCont animated:YES];
//}

    
//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [_mapView setVisibleMapRect:rect];
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
}

#pragma mark -
#pragma mark MRParkDetailTableViewControllerDelegate
- (void)parkDetailTableViewController:(MRParkDetailTableViewController *)detailVc btnDidClick:(UIButton *)btn
{
    if (btn.tag == 11) { // 前往
        Mylog(@"前往");
        [self gotoBtnClick];
    }else if (btn.tag == 12){ // 立即预约
        Mylog(@"立即预约");
        [MBProgressHUD showError:@"敬请期待!!!" toView:self.view];
    }

}


@end

