//
//  MRXMPPTool.m
//  WeChat
//
//  Created by 李白 on 15-7-6.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRXMPPTool.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "MRUserInfo.h"

/*
 * 在AppDelegate实现登录
 
 1. 初始化XMPPStream
 2. 连接到服务器[传一个JID]
 3. 连接到服务成功后，再发送密码授权
 4. 授权成功后，发送"在线" 消息
 */
@interface MRXMPPTool ()
{
    // xmpp流
    XMPPStream *_xmppStream;
    // 自定义回调block
    XMPPResultBlock _resultBlock;

//    // 电子名片  外界需要访问 应定义成公有的属性变量
//    XMPPvCardTempModule *_vCard;
    // 电子名片的数据存储
    XMPPvCardCoreDataStorage *_vCardStorage;
    // 头像模块
    XMPPvCardAvatarModule *_avatar;
    // 重连接模块
    XMPPReconnect *_reconnect;

    // 花名册
//    XMPPRoster *_roster;
    // 花名册存储
//    XMPPRosterCoreDataStorage *_rosterStorage;
    
}

- (void)setupXMPPStream;

- (void)connectToHost;

- (void)authenticateWithPassword;

- (void)sendOnlineToHost;

@end


@implementation MRXMPPTool

singleton_implementation(MRXMPPTool)

#pragma mark - 私有方法
- (void)setupXMPPStream
{
    // 打开XMPP自带的系统日志
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // 创建XMMP流
    _xmppStream = [[XMPPStream alloc] init];
    
    // 设置代理
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
#warning 每一个模块添加后都要激活
    
    // 添加电子名片模块
    _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
    // 激活电子名片模块
    [_vCard activate:_xmppStream];
    
    // 添加头像模块
    _avatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCard];
    
    [_avatar activate:_xmppStream];
    
    // 添加重连接模块
    _reconnect = [[XMPPReconnect alloc] init];
    [_reconnect activate:_xmppStream];
 
    // 添加花名册模块
    _rosterStorage = [XMPPRosterCoreDataStorage sharedInstance];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
    [_roster activate:_xmppStream];
    
}
- (void)connectToHost
{
    Mylog(@"开始连接到主机");
    // 判断是否存在XMPP流
    if (_xmppStream == nil) {
        [self setupXMPPStream];
    }
    
    MRUserInfo *userInfo = [MRUserInfo sharedMRUserInfo];
    
    NSString *account = nil;
    if (self.isRegisterUser) {
        account = userInfo.registerAccount;
    }else {
        account = userInfo.account;
    }
    
    // 设置登录用户JID
    //resource 标识用户登录的客户端 iphone android
    XMPPJID *myJID = [XMPPJID jidWithUser:account domain:@"libai.local" resource:@"iphone"];
    _xmppStream.myJID = myJID;
    
    // 设置服务器域名 也可以是IP
    _xmppStream.hostName = @"libai.local";
    // 设置主机端口
    _xmppStream.hostPort = 5222;
    
    // 连接主机
    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:-1 error:&error]) {
        Mylog(@"%@", error);
    }
}
- (void)authenticateWithPassword
{
    Mylog(@"发送密码进行授权");
    
    // 从沙盒中获取密码
    NSString *pwd = [MRUserInfo sharedMRUserInfo].pwd;
    NSError *error = nil;
    
    
    if (![_xmppStream authenticateWithPassword:pwd error:&error]) {
        Mylog(@"%@", error);
    }
}


- (void)sendOnlineToHost
{
    Mylog(@"发送'在线'消息");
    XMPPPresence *presence = [XMPPPresence presence];
    
    [_xmppStream sendElement:presence];
    
}

- (void)registerWithPassword
{
    Mylog(@"发送密码进行注册");
    // 从单例中获取注册密码
    NSString *pwd = [MRUserInfo sharedMRUserInfo].registerPwd;
    NSError *error = nil;
    if (![_xmppStream registerWithPassword:pwd error:&error]) {
        Mylog(@"%@", error);
    }
    
}

#pragma mark - 代理方法 XMPPStreamDelegate
/**
 *  连接到主机时调用
 *
 *  @param sender
 */
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    // 连接成功时发送密码进行登录或注册
    // 判读是注册还是登录
    if([self isRegisterUser]){  // 注册
        [self registerWithPassword];
    }else { // 登录
        [self authenticateWithPassword];
    }
    
    
}
/**
 *  与主机断开连接时调用
 *
 *  @param sender
 *  @param error
 */
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    Mylog(@"%@", error);
    
    if (error && _resultBlock) {
        _resultBlock(XMPPResultTypeNetError);
    }
}
/**
 *  获取授权时调用
 *
 *  @param sender
 */
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    Mylog(@"授权成功");
    // 发送在线消息
    [self sendOnlineToHost];
    
    // 回调控制器登录成功
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeSuccess);
    }
}
/**
 *  获取授权失败时调用
 *
 *  @param sender
 *  @param error
 */
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    Mylog(@"%@", error);
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeFailure);
    }
}
/**
 *  注册成功时调用
 *
 *  @param sender
 */
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    Mylog(@"注册成功");
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterSuccess);
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    NSLog(@"注册失败%@", error);
    if (error && _resultBlock) {
        _resultBlock(XMPPResultTypeRegisterFailure);
    }
    
}


#pragma mark - 公有方法 提供给外界访问
/**
 *  登录
 */
- (void)xmppUserLogin:(XMPPResultBlock)resultBlock
{
    // 先把block保存起来 以便其他地方拿到
    _resultBlock = resultBlock;
    
    // 判断是否有连接存在 如果有则断开
    //    if (_xmppStream.isConnected) {
    //        [_xmppStream disconnect];
    //    }
    // 或者 不管有没有都断开上一次的连接
    [_xmppStream disconnect];
    
    
    // 连接主机 成功后 发送密码授权
    [self connectToHost];
}

/**
 *  退出登录
 */
- (void)xmppUserLogout;
{
    Mylog(@"发送离线消息");
    // 发送离线消息
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
    
    // 与服务器断开连接
    [_xmppStream disconnect];
    
    // 跳转到登陆的storyboard
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    
    [UIApplication sharedApplication].keyWindow.rootViewController = storyBoard.instantiateInitialViewController;
    
    // 注销时设置登录状态为NO
    [MRUserInfo sharedMRUserInfo].loginStatus = NO;
    
}

- (void)xmppUserRegister:(XMPPResultBlock)resultBlock
{
    // 保存block
    _resultBlock = resultBlock;
    
    // 不管有没有都断开上一次的连接
    [_xmppStream disconnect];
    
    [self connectToHost];
    
}

- (void)dealloc
{
    [self tearDownXMPP];
}

#pragma mark - 释放XMPPStream资源
- (void)tearDownXMPP
{
    // 移除代理
    [_xmppStream removeDelegate:self];
    
    // 停止模块
    [_vCard deactivate];
    [_avatar deactivate];
    [_reconnect deactivate];
    [_roster deactivate];
    
    // 关闭连接
    [_xmppStream disconnect];
    
    // 清空资源
    _vCard = nil;
    _avatar = nil;
    _reconnect = nil;
    _roster = nil;
    _xmppStream = nil;
}


@end
