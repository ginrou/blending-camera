//
//  BCPartsPickerController.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/21.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCPathView.h"
#import "BCPartsBackgroundExtractionViewController.h"

@protocol BCPartsPickerControllerDelegate;

@interface BCPartsPickerController : UIViewController
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
BCPathViewDelegate,
BackgroundExtractionDelegate
>

@property (nonatomic, assign) id<BCPartsPickerControllerDelegate> delegate;
@property (nonatomic, strong) UIImage *originalImage;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) UIBarButtonItem *doneButton;

- (id)initWithPickerType:(UIImagePickerControllerSourceType)pickerType;
- (IBAction)clearButtonTapped:(id)sender;

@end

@protocol BCPartsPickerControllerDelegate <NSObject>

- (void)BCPartsPickerControllerPickDone:(BCPartsPickerController *)partsPicker partsImage:(UIImage *)image andMask:(UIImage *)mask;

- (void)BCPartsPickerControllerCanceld:(BCPartsPickerController *)partsPicker;

@end
