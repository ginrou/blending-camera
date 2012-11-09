//
//  BCImageSelectionViewController.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/21.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCImageSelectionViewController.h"

#import "BCBlenderRapper.h"

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
    [self setProcessingButton:nil];
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
    _processingButton.enabled = _baseImage && _partsImage;
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
    self.partsImageView = [[BCPartsView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    _partsImageView.image = image;
    [self.view insertSubview:_partsImageView aboveSubview:_baseImageView];
    
    _processingButton.enabled = _baseImage && _partsImage;
    
}

- (void)BCPartsPickerControllerCanceld:(BCPartsPickerController *)partsPicker
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma - mark start processing
- (IBAction)startProcessing:(id)sender
{
    dispatch_queue_t queue = dispatch_queue_create("TKDIndustry.bc.blend", NULL);
    dispatch_async(queue, ^{
        BCBlenderRapper *blender = [[BCBlenderRapper alloc] init];
        blender.sourceImage = [BCPartsView resizedImage:_partsImage ForSize:_partsImageView.frame.size];
        blender.targetImage = _baseImage;
        blender.mask        = [BCPartsView resizedGrayScaleImage:_maskImage ForSize:_partsImageView.frame.size];
        blender.offset      = _partsImageView.frame.origin;
        
        NSLog(@"%@", NSStringFromCGSize(blender.sourceImage.size));
        NSLog(@"%@", NSStringFromCGSize(blender.targetImage.size));
        NSLog(@"%@", NSStringFromCGSize(blender.mask.size));
        NSLog(@"%@", NSStringFromCGPoint(blender.offset));

        UIImage *dst = [blender WrappedSeamlessClone:true];

        [self blendingFinished:dst];
        
    });

    
}

- (void)blendingFinished:(UIImage *)blendImage;
{
    NSLog(@"blending finished");
    [self.partsImageView removeFromSuperview];
    self.partsImage = nil;
    self.maskImage  = nil;
    self.baseImage  = blendImage;
    
}

@end
