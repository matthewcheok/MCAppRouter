//
//  MCViewController.m
//  MCAppRouterDemo
//
//  Created by Matthew Cheok on 20/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import "MCViewController.h"
#import "MCAppRouter.h"

@interface MCViewController ()

@end

@implementation MCViewController

- (IBAction)handleColorButton:(id)sender {
	UIViewController *controller = [[MCAppRouter sharedInstance] viewControllerMatchingRoute:@"/color/#2C99F8/"];
	controller.title = @"Blue Controller";
	[self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)handleUserButton:(id)sender {
	[self.navigationController pushViewControllerMatchingRoute:@"user/201/display_name/Michael" animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
