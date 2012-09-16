//
//  BCViewController.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 12/09/16.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

-(IBAction)loadButtonTapped:(id)sender;

@end
