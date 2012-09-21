//
//  BCImageSelectionViewController.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/21.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCImageSelectionViewController.h"

@interface BCImageSelectionViewController ()
@property (nonatomic, assign) UIImagePickerController *baseImagePicker;
@property (nonatomic, assign) UIImagePickerController *partsPicker;

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
		_baseImagePicker = nil;
		_partsPicker = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:imagePicker animated:YES];
	self.baseImagePicker = imagePicker;
}

- (IBAction)loadBaseImageFromLibrary:(id)sender
{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentModalViewController:imagePicker animated:YES];
	self.baseImagePicker = imagePicker;
}

- (IBAction)loadPartsImageFromCamera:(id)sender
{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:imagePicker animated:YES];
	self.partsPicker = imagePicker;
	
}

- (IBAction)loadPartsImageFromLibrary:(id)sender
{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentModalViewController:imagePicker animated:YES];
	self.partsPicker = imagePicker;
}

#pragma --mark image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *loadedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	[self dismissModalViewControllerAnimated:YES];
	if (picker == _baseImagePicker) {
		self.baseImageView.image = loadedImage;
		self.baseImage = loadedImage;
		_baseImagePicker = nil;
		[self enableLoadingParts];
	} else if (picker == _partsPicker) {
		self.partsImageView.image = loadedImage;
		self.partsImage = loadedImage;
		_partsPicker = nil;
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
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
