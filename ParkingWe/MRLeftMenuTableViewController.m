//
//  MRLeftMenuTableViewController.m
//  ParkingWe
//
//  Created by 李白 on 15-7-30.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRLeftMenuTableViewController.h"

@interface MRLeftMenuTableViewController ()

@end

@implementation MRLeftMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_login"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
