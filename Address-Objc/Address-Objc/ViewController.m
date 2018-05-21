//
//  ViewController.m
//  Address-Objc
//
//  Created by Liu Chuan on 2018/10/4.
//  Copyright © 2018 LC. All rights reserved.
//

#import "ViewController.h"
#import "AddressViewController.h"

@interface ViewController ()

/**
 选择地址按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *addressButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.addressButton addTarget:self action:@selector(selectAddress) forControlEvents:UIControlEventTouchUpInside];
}

/**
 选择按钮点击事件
 */
-(void)selectAddress{
    AddressViewController *addressVC = [[AddressViewController alloc]init];
    UINavigationController *naVC = [[UINavigationController alloc]initWithRootViewController:addressVC];
    [self presentViewController:naVC animated:YES completion:nil];
}


@end
