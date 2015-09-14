//
//  MRRegisterViewController.m
//  WeChat
//
//  Created by 李白 on 15-7-5.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRRegisterViewController.h"
#import "AppDelegate.h"


@interface MRRegisterViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;
@property (weak, nonatomic) IBOutlet UITextField *registerAccountField;
@property (weak, nonatomic) IBOutlet UITextField *registerPwdField;

@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
- (IBAction)registerBtnClick:(id)sender;

- (IBAction)cancelBtnClick:(id)sender;

/**
 *  根据账号文本框和密码文本框的文章设置注册按钮是否可用
 */
- (IBAction)textEditChange;
@end

@implementation MRRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 判断是否是在iphone上，修改左右间距
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.leftConstraint.constant = 10;
        self.rightConstraint.constant = 10;
    }
    
    self.registerAccountField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    self.registerPwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    
    [self.registerBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
    
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
#pragma mark - 控制器内部方法
- (IBAction)cancelBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)textEditChange {
    if (self.registerAccountField.text.length > 0 && self.registerPwdField.text.length >0) {
        self.registerBtn.enabled = YES;
    }else {
        self.registerBtn.enabled = NO;
    }
    
}


- (IBAction)registerBtnClick:(id)sender {
    
    [self.view endEditing:YES];
    
    // 判断用户输入的注册账号是否是手机号码 不是给出提示 直接返回
    if (![self.registerAccountField isTelphoneNum]) {
        [MBProgressHUD showError:@"请输入正确的手机号码" toView:self.view];
        return;
    }
    
    // 把用户注册信息保存到单例
    MRUserInfo *userInfo = [MRUserInfo sharedMRUserInfo];
    userInfo.registerAccount = self.registerAccountField.text;
    userInfo.registerPwd = self.registerPwdField.text;
    
    [MBProgressHUD showMessage:@"注册中，请稍后..." toView:self.view];
    
    // 用户注册
    MRXMPPTool *xmppTool = [MRXMPPTool sharedMRXMPPTool];
    // 设置为注册类型
    xmppTool.registerUser = YES;
    __weak typeof(self) selfVc = self;
    [xmppTool xmppUserRegister:^(XMPPResultType type) {
        [selfVc handleWithResutType:type];
    }];
}

#pragma mark - 其他方法
/**
 *  处理注册结果
 *
 *  @param type 传入结果类型
 */
- (void)handleWithResutType:(XMPPResultType)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUDForView:self.view];
        switch (type) {
            case XMPPResultTypeNetError:
                Mylog(@"连接失败");
                [MBProgressHUD showError:@"网络错误，请检查网络连接" toView:self.view];
                break;
            case XMPPResultTypeRegisterSuccess:
                Mylog(@"注册成功");
                // 注册成功返回登录页面
                [self dismissViewControllerAnimated:YES completion:nil];
                // 注册成功保存注册信息到沙盒
                [[MRUserInfo sharedMRUserInfo] saveToSanbox];
                // 告诉代理注册完成
                if ([self.delegate respondsToSelector:@selector(registerViewControllerDidFinshedRegistere)]) {
                    [self.delegate registerViewControllerDidFinshedRegistere];
                }
                break;
            case XMPPResultTypeRegisterFailure:
                Mylog(@"注册失败");
                [MBProgressHUD showError:@"注册失败，用户名重复" toView:self.view];
            default:
                break;
        }
    });
}


@end
