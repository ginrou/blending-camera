//
//  BCImageSelectionViewController.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/21.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCImageSelectionViewController.h"

@interface BCImageSelectionViewController ()
@end

@implementation BCImageSelectionViewController
@synthesize choosePartsLabel;
@synthesize partsFromCameraButton;
@synthesize partsFromLibraryButton;
@synthesize firstRedArrow;
@synthesize baseImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		_baseImage = nil;
		_partsImage = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	
	[self enableLoadingParts];
	
}

- (void)viewDidUnload
{
    [self setBaseImageView:nil];
	[self setFirstRedArrow:nil];
	[self setChoosePartsLabel:nil];
	[self setPartsFromCameraButton:nil];
	[self setPartsFromLibraryButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -- image loaders
- (IBAction)loadBaseImageFromCamera:(id)sender
{
	[self showBaseImagePickerWithType:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)loadBaseImageFromLibrary:(id)sender
{
	[self showBaseImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showBaseImagePickerWithType:(UIImagePickerControllerSourceType)type
{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = type;
	[self presentModalViewController:imagePicker animated:YES];
}


- (IBAction)loadPartsImageFromCamera:(id)sender
{
	[self showPartsImagePickerWithType:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)loadPartsImageFromLibrary:(id)sender
{
	[self showPartsImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showPartsImagePickerWithType:(UIImagePickerControllerSourceType)type
{
	BCPartsPickerController *partsPicker = [[BCPartsPickerController alloc] initWithPickerType:type];
	partsPicker.delegate = self;
	[self presentModalViewController:partsPicker animated:YES];
}

#pragma -- mark image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *loadedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	[self dismissModalViewControllerAnimated:YES];
	self.baseImageView.image = loadedImage;
	self.baseImage = loadedImage;
	[self enableLoadingParts];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma -- mark parts picker delegate
- (void)BCPartsPickerControllerPickDone:(BCPartsPickerController *)partsPicker partsImage:(UIImage *)image andMask:(UIImage *)mask
{
	[self dismissModalViewControllerAnimated:YES];
	self.partsImage = image;
	self.maskImage  = mask;
	
}

- (void)BCPartsPickerControllerCanceld:(BCPartsPickerController *)partsPicker
{
	[self dismissModalViewControllerAnimated:YES];
}


- (void)enableLoadingParts
{
	firstRedArrow.hidden = NO;
	self.choosePartsLabel.hidden = NO;
	self.partsFromCameraButton.hidden = NO;
	self.partsFromLibraryButton.hidden = NO;
	self.partsImageView.hidden = NO;
}

@end
