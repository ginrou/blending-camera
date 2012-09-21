//
//  BCCaptureViewController.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/21.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCCaptureViewController.h"
#import "BCConfirmViewController.h"

@interface BCCaptureViewController ()
@property (nonatomic, strong) AVCaptureSession *captureSession;
@end

@implementation BCCaptureViewController
@synthesize previewView;

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
	if (![self cameraSetup])
		NSLog(@"cannot use camera with this device");

}


- (BOOL)cameraSetup
{
	AVCaptureDevice *camera = [self cameraWithPosition:AVCaptureDevicePositionBack];
	if (camera == nil) return NO;

	NSError *error = nil;
	AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
	if (error) return NO;
	
	_stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	_captureSession = [[AVCaptureSession alloc] init];
	[_captureSession addInput:videoInput];
	[_captureSession addOutput:_stillImageOutput];
	
	AVCaptureVideoPreviewLayer *videoLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
	videoLayer.frame = CGRectMake(0, 0, previewView.frame.size.width, previewView.frame.size.height);
	videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	
	CALayer *viewLayer = previewView.layer;
	viewLayer.masksToBounds = YES;
	[viewLayer addSublayer:videoLayer];
	
	return YES;
}


- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices) {
		if (device.position == position) {
			return device;
		}
	}
	return nil;
}

- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
	for (AVCaptureConnection *connection in connections) {
		for (AVCaptureInputPort *port in connection.inputPorts) {
			if ([port.mediaType isEqualToString:mediaType]) {
				return connection;
			}
		}
	}
	return nil;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[_captureSession startRunning];
}

- (void)viewDidUnload
{
	[self setPreviewView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)takePhotoButtonTapped:(id)sender
{
	AVCaptureConnection *connection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[_stillImageOutput connections]];
	[_stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
		if (imageDataSampleBuffer != NULL) {
			NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
			UIImage *capturedImage = [[UIImage alloc] initWithData:imageData];
			[self showConfirmViewWithImage:capturedImage];
		}
	}];
}

- (IBAction)loadPhotoButtonTapped:(id)sender
{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[self dismissModalViewControllerAnimated:NO];
	[self showConfirmViewWithImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)showConfirmViewWithImage:(UIImage *)targetImage
{
	BCConfirmViewController *confirmViewController = [[BCConfirmViewController alloc] init];
	confirmViewController.targetImage = targetImage;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:confirmViewController];
	[self presentModalViewController:navigationController animated:YES];
	[_captureSession stopRunning];
}

@end