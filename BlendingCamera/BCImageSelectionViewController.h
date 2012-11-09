//
//  BCImageSelectionViewController.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/21.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCPartsPickerController.h"
#import "BCPartsView.h"

@interface BCImageSelectionViewController : UIViewController
<
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate,
BCPartsPickerControllerDelegate>

// for image processing
@property (strong, nonatomic) UIImage *baseImage;
@property (strong, nonatomic) UIImage *partsImage;
@property (strong, nonatomic) UIImage *maskImage;

@property (nonatomic, strong) IBOutlet UIImageView *baseImageView;
@property (nonatomic, strong) BCPartsView *partsImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *processingButton;


- (IBAction)loadBaseImage:(id)sender;
- (IBAction)loadPartsImage:(id)sender;
- (IBAction)startProcessing:(id)sender;

@end
