//
//  BCPartsBackgroundExtractionViewController.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/11/23.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCPartsBackgroundExtractionViewController.h"
#import "BCBackgroundExtractor.h"
#import "BCImageConverter.h"

@interface BCPartsBackgroundExtractionViewController ()
{
    backgroundExtractor::BCBackgroundExtractor _extractor;
    dispatch_queue_t queue;
}

@end

@implementation BCPartsBackgroundExtractionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    cv::Mat originalMat = [BCImageConverter cvMatFromAlphaUIImage:_originalImage];
    _extractor.setImage(originalMat);
    UIImage *extracted = [BCImageConverter UIImageFromCVMat:_extractor.extract(_slider.value)];
    self.imageView.image = extracted;

    _bgColorSampler.backgroundColor = [UIColor colorWithRed:_extractor.bgColor[0]/256.0
                                                      green:_extractor.bgColor[1]/256.0
                                                       blue:_extractor.bgColor[2]/256.0
                                                      alpha:1.0];
    queue = dispatch_queue_create("TKDIndustry.bc.bgExtract", NULL);
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"done"
																   style:UIBarButtonItemStyleDone
																  target:self
																  action:@selector(doneButtonTapped:)];
	
	self.navigationItem.rightBarButtonItem = doneButton;
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setBgColorSampler:nil];
    [super viewDidUnload];
}
- (IBAction)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSLog(@"slider val = %f", slider.value);
    CGFloat valueForBlock = (slider.value) * (slider.value);
    dispatch_async(queue, ^{
        UIImage *extracted = [BCImageConverter UIImageFromCVMat:_extractor.extract(valueForBlock)];
        dispatch_async(dispatch_get_main_queue(), ^{
            _imageView.image = extracted;
            [self.view setNeedsDisplay];
        });
        NSLog(@"extract done %f", valueForBlock);
    });
}

- (void)doneButtonTapped:(id)sender
{
	CGFloat valueForBlock = _slider.value * _slider.value;
	if ([self.delegate respondsToSelector:@selector(backgroundExtractionDone:)]) {
		dispatch_async(queue, ^{

			UIImage *newMask = [BCImageConverter UIImageFromCVMat:_extractor.newMaskImage(valueForBlock)];
			UIImage *newExtract = [BCImageConverter UIImageFromCVMat:_extractor.newOriginalImage(valueForBlock)];
			dispatch_async(dispatch_get_main_queue(), ^{
				self.extractedMaskImage = newMask;
				self.extractedImage = newExtract;
				[self.delegate backgroundExtractionDone:self];
			});

		});

	}
}

@end
