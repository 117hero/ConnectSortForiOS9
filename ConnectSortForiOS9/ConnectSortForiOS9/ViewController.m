//
//  ViewController.m
//  ConnectSortForiOS9
//
//  Created by anyongxue on 16/7/29.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "ViewController.h"

#import "ConnectViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

   
}

//获取系统相册
- (IBAction)getConnectAction:(id)sender {
    
    ConnectViewController *connectVC = [[ConnectViewController alloc] init];
    
    [self.navigationController pushViewController:connectVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
