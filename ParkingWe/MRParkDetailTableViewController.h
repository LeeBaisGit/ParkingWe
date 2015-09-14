//
//  MRParkDetailTableViewController.h
//  ParkingWe
//
//  Created by 李白 on 15-8-20.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRParkDetailTableViewController;
@protocol MRParkDetailTableViewControllerDelegate <NSObject>

@optional
- (void)parkDetailTableViewController:(MRParkDetailTableViewController *)detailVc btnDidClick:(UIButton *)btn;

@end


@class BMKPoiDetailResult;
@interface MRParkDetailTableViewController : UITableViewController

@property(nonatomic,strong)BMKPoiDetailResult *detailResult;

@property(nonatomic,weak)id<MRParkDetailTableViewControllerDelegate> delegate;

@end
