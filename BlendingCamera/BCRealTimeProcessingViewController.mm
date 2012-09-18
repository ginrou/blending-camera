//
//  BCRealTimeProcessingViewController.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/17.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCRealTimeProcessingViewController.h"

@interface BCRealTimeProcessingViewController ()

@end

@implementation BCRealTimeProcessingViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"realtime";
	
	_videoCamera = [[CvVideoCamera alloc] initWithParentView:_imageView];
	_videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
	_videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
	_videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
	_videoCamera.defaultFPS = 30;
	_videoCamera.grayscaleMode = YES;
	_videoCamera.delegate = self;
	//_videoCamera.useAVCaptureVideoPreviewLayer = YES;
}

- (void)viewDidUnload
{
	_imageView = nil;
	_button = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)buttonTapped:(id)sender
{
	_videoCamera.running ? [_videoCamera stop] : [_videoCamera start];
}

- (void)processImage:(cv::Mat &)image
{
	Mat current = image.clone();

	
	
	*previousMat = current;
}




@end
