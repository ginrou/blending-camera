//
//  ViewController.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/17.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <GLKit/GLKit.h>

#import "ViewController.h"
#import "DistOptionTableViewController.h"
#import "DistImageProcessor.h"

@interface FaceViewController ()
{

}
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, assign) CGSize captureSize;
@property (nonatomic, assign) CGSize outputSize;

@property (nonatomic, strong) DistOptionTableViewController *optionViewController;
@property (nonatomic, strong) DistImageProcessor *processor;

@end

@implementation FaceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAVCaputre];
    [_previewView setupWithFrame:CGRectZero error:nil];

    self.processor = [[DistImageProcessor alloc] initWithEAGLContext:_previewView.context]; // depends on _previewView
    
    [self setupOutputSize];
    
    _toolbar.height = 60.0;
    _toolbar.bottom = self.view.height;
    
}

- (void)viewDidUnload {
    self.toolbar = nil;
    self.optionViewController = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark initialize methods
- (void)setupAVCaputre
{
    NSError *error = nil;
    self.session = [AVCaptureSession new];
    [_session beginConfiguration];
    [_session setSessionPreset:AVCaptureSessionPreset640x480];
    self.captureSize = CGSizeMake(480, 640);


    //AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *frontCamera;
    for (AVCaptureDevice *device in devices) {
        if (device.position == AVCaptureDevicePositionFront) {
            frontCamera = device;
            break;
        }
    }

    error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
    [_session addInput:input];


    // make a still image output


    // make a video data output
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];

    [_videoDataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    [_videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];

    // create a serial dispatch queue
    _videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [_videoDataOutput setSampleBufferDelegate:self queue:_videoDataOutputQueue];

    [_session addOutput:_videoDataOutput];
    [[_videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    [_session commitConfiguration];
    [_session startRunning];
}



#pragma mark -- processings
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // got an image
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer options:(NSDictionary *)CFBridgingRelease(attachments)];


    UIDeviceOrientation deviceOrientaion = [[UIDevice currentDevice] orientation];
    int exifOrientation;

	enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
	};

	switch (deviceOrientaion) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}

    NSDictionary *imageOption = @{CIDetectorImageOrientation : [NSNumber numberWithInt:exifOrientation]};
    CIImage *outputImage = [_processor applyEffect:ciImage options:imageOption];

    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeRotation(-M_PI / 2.0)];
    CGPoint origin = outputImage.extent.origin;
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeTranslation(-origin.x, -origin.y)];

    CGRect inRect = CGRectMake(0, 0, _outputSize.width, _outputSize.height);
    CGRect fromRect = CGRectMake(0, 0, 480, 640);
    [_processor.ciContext drawImage:outputImage inRect:inRect fromRect:fromRect];

    dispatch_async(dispatch_get_main_queue(), ^{
        [_previewView updateView];
    });
}

- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSLog(@"saved %@", error);
}

#pragma mark - view utilities

- (void)setupOutputSize
{
    CGFloat maxWitdh = _previewView.frame.size.width * 2;
    CGFloat maxHeight = _previewView.frame.size.height * 2;

    CGFloat scale = ( maxHeight > maxWitdh) ? maxHeight / _captureSize.height : maxWitdh / _captureSize.width;

    _outputSize.height = scale * _captureSize.height;
    _outputSize.width = scale * _captureSize.width;

}


#pragma mark actions
- (IBAction)expandBottomBar:(id)sender
{
    if (_optionViewController) {
        [self hideOptionViewController];
    } else {
        [self showOptionViewController];
    }
}

- (void)hideOptionViewController
{
    [UIView animateWithDuration:0.25 animations:^{
        _optionViewController.view.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_optionViewController.view removeFromSuperview];
        self.optionViewController = nil;
    }];
}

- (void)showOptionViewController
{
    self.optionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DistOptionTableViewController"];

    _optionViewController.view.alpha = 0.f;
    [self.view addSubview:_optionViewController.view];
    _optionViewController.view.bottom = _toolbar.top - 5.0;

    [UIView animateWithDuration:0.25 animations:^{
        _optionViewController.view.alpha = 1.0;
    } completion:nil];

}

@end
