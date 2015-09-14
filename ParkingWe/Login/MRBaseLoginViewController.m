//
//  MRBaseLoginViewController.m
//  WeChat
//
//  Created by 李白 on 15-7-5.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRBaseLoginViewController.h"
#import "AppDelegate.h"


@interface MRBaseLoginViewController ()

@end

@implementation MRBaseLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)login
{
        [self.view endEditing:YES];
        
        // 添加提示遮盖
        [MBProgressHUD showMessage:@"正在登录中..." toView:self.view];
        
        // 登录
        MRXMPPTool *xmppTool = [MRXMPPTool sharedMRXMPPTool];
    
        // 设置为登录类型
        xmppTool.registerUser = NO;
    
        __weak typeof(self) selfVc = self; // block中使用 先转为weak 防止循环引用
        [xmppTool xmppUserLogin:^(XMPPResultType type) {
            [selfVc handleResultType:type];
        }];
    
}



#pragma mark - 其他方法
- (void)handleResultType:(XMPPResultType)type
{
    // 回到主线程刷新UI    所有的UI刷新都应该在UI中操作
    dispatch_async(dispatch_get_main_queue(), ^{
        // 隐藏提示遮盖
        [MBProgressHUD hideHUDForView:self.view];
        switch (type) {
            case XMPPResultTypeSuccess:
                Mylog(@"登录成功");
                [self enterMainPage];
                // 登录成功时设置登录状态为YES
                [MRUserInfo sharedMRUserInfo].loginStatus = YES;
                // 保存账号和密码到沙盒
                [[MRUserInfo sharedMRUserInfo] saveToSanbox];
                
                break;
            case XMPPResultTypeFailure:
                Mylog(@"登录失败");
                [MBProgressHUD showError:@"用户名或密码错误" toView:self.view];
                break;
            case XMPPResultTypeNetError:
                [MBProgressHUD showError:@"网络不给力" toView:self.view];
            default:
                break;
        }
    });
}



/**
 *  进入主页面
 */
- (void)enterMainPage
{
    Mylog(@"------");
    // dismiss当前控制器
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 加载main.storyboard
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // 设为窗口的根控制器
    [UIApplication sharedApplication].keyWindow.rootViewController = storyBoard.instantiateInitialViewController;
    
}






@end
