//
//  MRXMPPTool.h
//  WeChat
//
//  Created by 李白 on 15-7-6.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"


@interface MRXMPPTool : NSObject
typedef enum {
    XMPPResultTypeSuccess, // 登录成功
    XMPPResultTypeFailure,  // 登录失败
    XMPPResultTypeNetError, // 网络错误
    XMPPResultTypeRegisterSuccess, // 注册成功
    XMPPResultTypeRegisterFailure // 注册失败
}XMPPResultType;

typedef void (^XMPPResultBlock)(XMPPResultType type); // XMPP请求结果的block

singleton_interface(MRXMPPTool)

/**
 *  登录
 */
- (void)xmppUserLogin:(XMPPResultBlock)resultBlock;

/**
 *  退出登录
 */
- (void)xmppUserLogout;

/**
 *  注册
 *
 *  @param resultBlock 回调的block
 */
- (void)xmppUserRegister:(XMPPResultBlock)resultBlock;
/**
 *  用于判断是否是用户注册 YES 注册/ NO 登录
 */
@property(nonatomic,assign,getter=isRegisterUser)BOOL registerUser;

/**
 *  电子名片
 */
@property(nonatomic,strong)XMPPvCardTempModule *vCard;

/**
 *  花名册
 */
@property(nonatomic,strong)XMPPRoster *roster;

@property(nonatomic,strong)XMPPRosterCoreDataStorage *rosterStorage;

@end
