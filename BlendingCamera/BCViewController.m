//
//  BCViewController.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 12/09/16.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCViewController.h"

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
//    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//    imagePicker.delegate = self;
//    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    [self presentModalViewController:imagePicker animated:YES];
	
	[self imageProcessing];
	
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
	BCBlenderRapper *bld = [[BCBlenderRapper alloc] init];
	bld.sourceImage = [UIImage imageNamed:@"vinci_src"];
	bld.targetImage = [UIImage imageNamed:@"vinci_target"];
	bld.mask        = [UIImage imageNamed:@"vinci_mask"];
	bld.offset      = CGPointMake(-31.0, 31.0);
    _imageView.image = [bld WrappedSeamlessClone:true];
    
}


@end
