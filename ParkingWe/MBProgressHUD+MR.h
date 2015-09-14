//
//  MBProgressHUD+MR.h
//  ParkingWe
//
//  Created by 李白 on 15-8-20.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (MR)

+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;


+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (MBProgressHUD *)showMessage:(NSString *)message;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;

@end
