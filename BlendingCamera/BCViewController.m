//
//  BCViewController.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 12/09/16.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCViewController.h"
#import "BCImageConverter.h"

@interface BCViewController ()

@end

@implementation BCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"single";
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(IBAction)loadButtonTapped:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    _imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self imageProcessing];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imageProcessing
{
    cv::Mat inputMat = [BCImageConverter cvMatFromUIImage:_imageView.image];
    cv::Mat hsvMat;
    cv::cvtColor(inputMat, hsvMat, CV_BGR2HSV);
    UIImage *hsv = [BCImageConverter UIImageFromCVMat:hsvMat];
    _imageView.image = hsv;
    
}


@end
