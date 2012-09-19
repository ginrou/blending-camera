//
//  BCViewController.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 12/09/16.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#ifndef __BC_VIEW_CONTROLLER__
#define __BC_VIEW_CONTROLLER__

#import <UIKit/UIKit.h>
#import "BCBlenderRapper.h"

@interface BCViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

-(IBAction)loadButtonTapped:(id)sender;

@end

#endif