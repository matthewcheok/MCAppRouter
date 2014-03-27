//
//  MCAppRouter.h
//  MCAppRouterDemo
//
//  Created by Matthew Cheok on 20/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCAppRouter;

@interface UINavigationController (MCAppRouter)

- (void)pushViewControllerMatchingRoute:(NSString *)route animated:(BOOL)animated;

@end

@interface MCAppRouter : NSObject

+ (instancetype)sharedInstance;

- (void)mapRoute:(NSString *)route toViewControllerClass:(Class)class;
- (void)mapRoute:(NSString *)route toViewControllerInStoryboardWithName:(NSString *)name withIdentifer:(NSString *)identifer;

- (id)viewControllerMatchingRoute:(NSString *)route;

@end
