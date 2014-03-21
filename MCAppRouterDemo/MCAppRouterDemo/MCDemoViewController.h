//
//  MCDemoViewController.h
//  MCAppRouterDemo
//
//  Created by Matthew Cheok on 21/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCDemoViewController : UIViewController

@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *userName;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
