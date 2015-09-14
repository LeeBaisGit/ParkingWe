//
//  MRParkDetailTableViewController.m
//  ParkingWe
//
//  Created by 李白 on 15-8-20.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRParkDetailTableViewController.h"
#import <BaiduMapAPI/BMapKit.h>

@interface MRParkDetailTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCount;
@property (weak, nonatomic) IBOutlet UILabel *leftCount;
@property (weak, nonatomic) IBOutlet UILabel *fees;

@property (weak, nonatomic) IBOutlet UILabel *descripLabel;

- (IBAction)gotoBtnClick:(id)sender;

- (IBAction)orderBtnClick:(id)sender;



@end

@implementation MRParkDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIImageView *headerImageView = [[UIImageView alloc] init];
//    headerImageView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg_parkdetail"]];
    headerImageView.frame = CGRectMake(0, 0, 320, 100);
    headerImageView.backgroundColor = [UIColor grayColor];
    
    headerImageView.userInteractionEnabled = YES;

    self.tableView.tableHeaderView = headerImageView;

    Mylog(@"%@", headerImageView.superview);
    
//    [headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view);
//        make.left.equalTo(self.view);
//        make.right.equalTo(self.view);
//        make.height.equalTo(@200);
//    }];
    
    
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"UMS_nav_button_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [headerImageView addSubview:backBtn];

    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.topMargin.equalTo(@33);
        make.leftMargin.equalTo(@13);
        make.width.equalTo(@24);
        make.height.equalTo(@24);
    }];
    
    
    self.tableView.allowsSelection = NO;
    self.tableView.scrollEnabled = NO;

    self.addressLabel.text = @"asdfasdfsa";
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.addressLabel.text = self.detailResult.address;
    self.typeLabel.text = self.detailResult.type;
    self.totalCount.text = self.detailResult.phone;
    self.leftCount.text = self.detailResult.tag;
    self.fees.text = [NSString stringWithFormat:@"%f元",self.detailResult.price];;
    self.descripLabel.text = self.detailResult.detailUrl;

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (void)backBtnClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (IBAction)gotoBtnClick:(id)sender {
    
    Mylog(@"前往");
    
    [self backBtnClick];
    
    if ([self.delegate respondsToSelector:@selector(parkDetailTableViewController:btnDidClick:)]) {
        [self.delegate parkDetailTableViewController:self btnDidClick:sender];
    }
    
    
}

- (IBAction)orderBtnClick:(id)sender {
    Mylog(@"立即预约");
    
    [self backBtnClick];
    
    if ([self.delegate respondsToSelector:@selector(parkDetailTableViewController:btnDidClick:)]) {
        [self.delegate parkDetailTableViewController:self btnDidClick:sender];
    }
}

- (void)setDetailResult:(BMKPoiDetailResult *)detailResult
{
    
    Mylog(@"%@",[NSThread currentThread]);
    
    _detailResult = detailResult;
}


@end
