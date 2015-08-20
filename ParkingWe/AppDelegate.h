//
//  AppDelegate.h
//  ParkingWe
//
//  Created by 李白 on 15-7-28.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate>
{
    BMKMapManager* _mapManager;
}

@property (strong, nonatomic) UIWindow *window;


@end

