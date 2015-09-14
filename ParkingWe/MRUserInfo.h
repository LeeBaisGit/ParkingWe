//
//  MRUserInfo.h
//  WeChat
//
//  Created by 李白 on 15-7-5.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface MRUserInfo : NSObject

singleton_interface(MRUserInfo)
/**
 *  账号
 */
@property(nonatomic,copy)NSString *account;
/**
 *  密码
 */
@property(nonatomic,copy)NSString *pwd;

/**
 *  保存用户信息到沙盒中
 */
- (void)saveToSanbox;
/**
 *  从沙盒中读取用户信息
 */
- (void)loadFromSanbox;

/**
 *  登录状态 YES 登录/NO 注销
 */
@property(nonatomic,assign) BOOL loginStatus;

/**
 *  注册账号
 */
@property(nonatomic,copy)NSString *registerAccount;
/**
 *  注册密码
 */
@property(nonatomic,copy)NSString *registerPwd;
/**
 *  当前登录用户的jid
 */
@property(nonatomic,copy)NSString *jid;

@end
