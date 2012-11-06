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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    _baseImageView.contentMode = UIViewContentModeScaleAspectFit;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




#pragma mark - ===========image loaders============== -
#pragma mark load base image

- (IBAction)loadBaseImage:(id)sender { [self showActionSheetWithTag:0]; }

- (void)loadBaseImageFromPicker:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    [self presentModalViewController:imagePicker animated:YES];
}

#pragma mark load parts image

- (IBAction)loadPartsImage:(id)sender { [self showActionSheetWithTag:1]; }

- (void)showPartsImagePickerWithType:(UIImagePickerControllerSourceType)type
{
	BCPartsPickerController *partsPicker = [[BCPartsPickerController alloc] initWithPickerType:type];
	partsPicker.delegate = self;
	[self presentModalViewController:partsPicker animated:YES];
}

#pragma mark - ============ Delegates ============ -
#pragma mark UIActionSheet Creator and Delegates
- (void)showActionSheetWithTag:(NSInteger)tag
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"load from Library", @"take a photo", nil];
    actionSheet.tag = tag;
    [actionSheet showInView:self.view.window];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerControllerSourceType sourceType;
    if (buttonIndex == 0) sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    else if (buttonIndex == 1) sourceType = UIImagePickerControllerSourceTypeCamera;
    else return;
    
    if (actionSheet.tag == 0) [self loadBaseImageFromPicker:sourceType];
    else if (actionSheet.tag == 1) [self showPartsImagePickerWithType:sourceType];
}


#pragma -- mark image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *loadedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	[self dismissModalViewControllerAnimated:YES];
	self.baseImage = loadedImage;
    self.baseImageView.image = _baseImage;
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
    self.partsImageView = [[BCPartsView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    _partsImageView.image = image;
    [self.view insertSubview:_partsImageView aboveSubview:_baseImageView];
    
    //self.maskImage  = mask;

}

- (void)BCPartsPickerControllerCanceld:(BCPartsPickerController *)partsPicker
{
	[self dismissModalViewControllerAnimated:YES];
}


@end
