//
//  MROtherLoginViewController.m
//  WeChat
//
//  Created by 李白 on 15-7-4.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MROtherLoginViewController.h"
#import "AppDelegate.h"


@interface MROtherLoginViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;
@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

- (IBAction)loginBtnClick:(id)sender;

- (IBAction)cancelBtnClick:(id)sender;


@end

@implementation MROtherLoginViewController


#pragma mark - 系统方法

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 判断是ipad还是iPhone 改变左右两边约束
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.leftConstraint.constant = 10;
        self.rightConstraint.constant = 10;
    }
    
    // 设置文本输入框的背景
    self.accountField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    
    [self.loginBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
    
    
    
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

- (void)dealloc
{
    Mylog(@"-----");
}

#pragma mark - 控制器器内部方法
- (IBAction)cancelBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginBtnClick:(id)sender {
    // 获取账户名 和 密码
    NSString *account = self.accountField.text;
    NSString *pwd = self.pwdField.text;
    if (account != nil  && account.length > 0 && pwd != nil && pwd.length > 0) {
        // 给单例userInfo赋值
        MRUserInfo *userInfo = [MRUserInfo sharedMRUserInfo];
        userInfo.account = account;
        userInfo.pwd = pwd;
        
        [super login];
    }
}


@end
