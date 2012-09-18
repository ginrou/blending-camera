//
//  BCAppDelegate.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 12/09/16.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCViewController;

@interface BCAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BCViewController *viewController;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) NSMutableArray *viewControllers;

@end
