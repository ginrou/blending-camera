//
//  BCImageSelectionViewController.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/21.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCImageSelectionViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *firstRedArrow;

@property (weak, nonatomic) IBOutlet UIImageView *baseImageView;
@property (strong, nonatomic) UIImage *baseImage;

@property (weak, nonatomic) IBOutlet UIImageView *partsImageView;
@property (strong, nonatomic) UIImage *partsImage;

@property (weak, nonatomic) IBOutlet UILabel *choosePartsLabel;
@property (weak, nonatomic) IBOutlet UIButton *partsFromCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *partsFromLibraryButton;

- (IBAction)loadBaseImageFromCamera:(id)sender;
- (IBAction)loadBaseImageFromLibrary:(id)sender;

- (IBAction)loadPartsImageFromCamera:(id)sender;
- (IBAction)loadPartsImageFromLibrary:(id)sender;


@end
