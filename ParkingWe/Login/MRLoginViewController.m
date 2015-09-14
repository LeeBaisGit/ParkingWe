//
//  MRLoginViewController.m
//  WeChat
//
//  Created by 李白 on 15-7-4.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRLoginViewController.h"
#import "MRRegisterViewController.h"


@interface MRLoginViewController ()<MRRegisterViewControllerDelegate>

/**
 *  账号
 */
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

/**
 *  密码
 */
@property (weak, nonatomic) IBOutlet UITextField *pwdField;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

/**
 *  登录按钮点击
 */
- (IBAction)loginBtnClick:(id)sender;
@end

@implementation MRLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.accountLabel.text = [MRUserInfo sharedMRUserInfo].account;
    
    // 设置文本输入框的背景
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    // 设置文本输入框左边的图片
    [self.pwdField addLeftViewWithImage:@"Card_Lock"];
    
    [self.loginBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    Mylog(@"----");
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id destVc = segue.destinationViewController;
    // 由于MRRegisterViewController是由导航控制器push出来的，所有segue的目标控制器是导航控制器，导航控制器的栈顶控制器才是MRRegisterViewController
    if ([destVc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = destVc;
        if ([nav.topViewController isKindOfClass:[MRRegisterViewController class]])
        {
            MRRegisterViewController *registerVc =(MRRegisterViewController *)nav.topViewController;
            // 设置注册控制器的代理为登录控制器
            registerVc.delegate = self;
        }
        
    }
    
}

#pragma mark - 私有方法
- (IBAction)loginBtnClick:(id)sender {
    
    NSString *account = self.accountLabel.text;
    NSString *pwd = self.pwdField.text;
    if (account != nil  && account.length > 0 && pwd != nil && pwd.length > 0) {
        // 给单例userInfo赋值
        MRUserInfo *userInfo = [MRUserInfo sharedMRUserInfo];
        userInfo.account = account;
        userInfo.pwd = pwd;
        
        [super login];
    }
    
}

#pragma mark -  MRRegisterViewControllerDelegate
- (void)registerViewControllerDidFinshedRegistere
{
    // 完成注册后，设置登录控制器账号label显示注册的账号
    self.accountLabel.text = [MRUserInfo sharedMRUserInfo].registerAccount;
    // 提示
    [MBProgressHUD showSuccess:@"请重新输入密码进行登录" toView:self.view];
}


@end
