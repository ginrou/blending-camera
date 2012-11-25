//
//  BCPartsBackgroundExtractionViewController.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/11/23.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackgroundExtractionDelegate;

@interface BCPartsBackgroundExtractionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *bgColorSampler;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (strong, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) UIImage *extractedImage;
@property (strong, nonatomic) UIImage *extractedMaskImage;
@property (nonatomic, weak) id<BackgroundExtractionDelegate> delegate;

- (IBAction)sliderValueChanged:(id)sender;

@end

@protocol BackgroundExtractionDelegate <NSObject>
- (void)backgroundExtractionDone:(BCPartsBackgroundExtractionViewController *)extractionViewController;
@end