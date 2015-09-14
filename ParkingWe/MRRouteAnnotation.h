//
//  MRRouteAnnotation.h
//  ParkingWe
//
//  Created by 李白 on 15-8-17.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import <BaiduMapAPI/BMapKit.h>

typedef enum {
    MRRouteAnnotationTypeStart, // 起点
    MRRouteAnnotationTypeEnd, // 终点
    MRRouteAnnotationTypeBus, // 公交
    MRRouteAnnotationTypeSubway, // 地铁
    MRRouteAnnotationTypeDrive, //  驾乘
    MRRouteAnnotationTypeWayPoint // 途经点
}MRRouteAnnotationType;

@interface MRRouteAnnotation : BMKPointAnnotation

@property(nonatomic,assign)MRRouteAnnotationType type;

@property(nonatomic,assign)int degree;

@property(nonatomic,copy)NSString *poiUid;

@end
