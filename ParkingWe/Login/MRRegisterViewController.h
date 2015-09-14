//
//  MRRegisterViewController.h
//  WeChat
//
//  Created by 李白 on 15-7-5.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MRRegisterViewController;
@protocol MRRegisterViewControllerDelegate <NSObject>

@optional
/**
 *  注册完成后告诉登录控制器
 *
 *  @param registerVc 
 */
- (void)registerViewControllerDidFinshedRegistere;

@end

@interface MRRegisterViewController : UIViewController

@property(nonatomic,weak)id<MRRegisterViewControllerDelegate> delegate;

@end
