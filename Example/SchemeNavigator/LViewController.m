//
//  LViewController.m
//  SchemeNavigator
//
//  Created by liuzhen on 08/26/2017.
//  Copyright (c) 2017 liuzhen. All rights reserved.
//

#import "LViewController.h"

@import SchemeNavigator;

@interface LViewController ()

@end

@implementation LViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)show:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://www.qq.com"];
    [[SchemeNavigator sharedNavigator] openURL:url];
}

@end
