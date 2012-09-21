//
//  BCCaptureViewController.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/21.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface BCCaptureViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

- (IBAction)takePhotoButtonTapped:(id)sender;
- (IBAction)loadPhotoButtonTapped:(id)sender;

@end
