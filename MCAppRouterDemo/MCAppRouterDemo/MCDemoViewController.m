//
//  MCDemoViewController.m
//  MCAppRouterDemo
//
//  Created by Matthew Cheok on 21/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import "MCDemoViewController.h"

@interface MCDemoViewController ()

@end

@implementation MCDemoViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.

	if (self.userID) {
		self.title = [NSString stringWithFormat:@"User #%@", self.userID];
	}
	if (self.userName) {
		self.titleLabel.text = self.userName;
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
