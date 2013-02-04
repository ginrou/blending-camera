//
//  ViewController.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/17.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <GLKit/GLKit.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "ViewController.h"
#import "DistOptionTableViewController.h"
#import "DistImageProcessor.h"
#import "DistOptions.h"
#import "DistControllToolBar.h"
#import "DistFilterSelectionViewController.h"

@interface FaceViewController ()
{
    
}

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, assign) CGSize captureSize;
@property (nonatomic, assign) CGSize outputSize;
@property (nonatomic, assign) BOOL isFrontFacing;

@property (nonatomic, strong) DistOptionTableViewController *optionViewController;
@property (nonatomic, strong) DistImageProcessor *processor;
@property (nonatomic, strong) DistFilterSelectionViewController *filterSelectionViewController;
@property (nonatomic, strong) DistControllToolBar *controllTabBar;

@property (nonatomic, strong) UIView *flashView;

@property (nonatomic, strong) UIImageView *stillImageView;

@property (nonatomic, assign) dispatch_queue_t videoDataOutputQueue;

@end

// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";



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
    _toolbar.alpha = 0.f;

    self.controllTabBar = [[DistControllToolBar alloc] initWithFrame:_toolbar.frame];
    self.controllTabBar.delegate = self;
    [self.view addSubview:_controllTabBar];

    self.isFrontFacing = YES;
    
    self.stillImageView = [[UIImageView alloc] initWithFrame:_previewView.frame];
    _stillImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:_stillImageView belowSubview:_controllTabBar];
    _stillImageView.contentMode = UIViewContentModeScaleAspectFit;
    

    [self start];
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
    [_session setSessionPreset:AVCaptureSessionPreset1280x720];
    self.captureSize = CGSizeMake(720, 1280);
    
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *frontCamera = nil;
    for (AVCaptureDevice *device in devices) {
        if (device.position == AVCaptureDevicePositionFront) {
            frontCamera = device;
            break;
        }
    }
    
    error = nil;
    if (!frontCamera) {
        self.session = nil;
        return;
    }
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
    [_session addInput:input];
    
    
    // make a still image output
    self.stillImageOutput = [AVCaptureStillImageOutput new];
    [_stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:(__bridge void *)(AVCaptureStillImageIsCapturingStillImageContext)];
    [_stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA]
                                                                     forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [_session addOutput:_stillImageOutput];


    // make a video data output
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    [_videoDataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    [_videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    // create a serial dispatch queue
    self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [_videoDataOutput setSampleBufferDelegate:self queue:_videoDataOutputQueue];
    dispatch_retain(_videoDataOutputQueue);
    
    [_session addOutput:_videoDataOutput];
    [_session commitConfiguration];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == (__bridge void *)(AVCaptureStillImageIsCapturingStillImageContext)
        && [DistOptions loadFlash])
    {
		BOOL isCapturingStillImage = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
		
		if ( isCapturingStillImage ) {
			// do flash bulb like animation
			self.flashView = [[UIView alloc] initWithFrame:[_previewView frame]];
			[_flashView setBackgroundColor:[UIColor whiteColor]];
			[_flashView setAlpha:1.f];
			[self.view.window addSubview:_flashView];
			
			[UIView animateWithDuration:.4f animations:^{
                [_flashView setAlpha:1.f];
            }];
		}
		else {
			[UIView animateWithDuration:.4f animations:^{
                [_flashView setAlpha:0.f];
            } completion:^(BOOL finished){
                [_flashView removeFromSuperview];
                self.flashView = nil;
            }];
		}
	}
}

#pragma mark -- processings
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{

    if (_stillImageOutput.isCapturingStillImage) return;


    // got an image
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer options:(NSDictionary *)CFBridgingRelease(attachments)];
    
    
    UIDeviceOrientation deviceOrientaion = [[UIDevice currentDevice] orientation];
    static int exifOrientation = 1;

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

    CIImage *outputImage = [_processor applyEffect:ciImage options:@{CIDetectorImageOrientation : [NSNumber numberWithInt:exifOrientation]}];
    outputImage = [self applyRotationForCurrentOrientation:outputImage];
    
    CGRect inRect = CGRectMake(0, 0, _outputSize.width, _outputSize.height);
    CGRect fromRect = CGRectMake(0, 0, _captureSize.width, _captureSize.height);

    dispatch_async(dispatch_get_main_queue(), ^{
        [_processor.ciContext drawImage:outputImage inRect:inRect fromRect:fromRect];
        [self.previewView updateView];
    });
}


// main action method to take a still image -- if face detection has been turned on and a face has been detected
// the square overlay will be composited on top of the captured image and saved to the camera roll
- (void)takePicture:(DistControllToolBar *)toolBar
{
	// Find out the current orientation and tell the still image output.
	AVCaptureConnection *stillImageConnection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];

    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [stillImageConnection setVideoOrientation:avcaptureOrientation];

	[_stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {

        if (error) {
            NSLog(@"failed to take picture, %@", error);
            return ;
        }
        // Got an image.

        // when processing an existing frame we want any new frames to be automatically dropped
        // queueing this block to execute on the videoDataOutputQueue serial queue ensures this
        // see the header doc for setSampleBufferDelegate:queue: for more information
        dispatch_sync(_videoDataOutputQueue, ^(void) {
            // still be based on those of the image.

            CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(imageDataSampleBuffer);
            CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
            CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(NSDictionary *)CFBridgingRelease(attachments)];

            NSDictionary *imageOptions = nil;
            NSNumber *orientation = (__bridge NSNumber *)(CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyOrientation, NULL));
            if (orientation) imageOptions = [NSDictionary dictionaryWithObject:orientation forKey:CIDetectorImageOrientation];

            CIImage *outputImage = [_processor applyEffect:ciImage options:imageOptions];
            outputImage = [self applyRotationForCurrentOrientation:outputImage];
            UIImage *uiImage = [UIImage imageWithCIImage:outputImage];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self takePictureDone:uiImage];
            });

        });

    }];
}

// utility routing used during image capture to set up capture orientation
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
	AVCaptureVideoOrientation result = deviceOrientation;
	if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
		result = AVCaptureVideoOrientationLandscapeRight;
	else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
		result = AVCaptureVideoOrientationLandscapeLeft;
	return result;
}

- (CIImage *)applyRotationForCurrentOrientation:(CIImage *)ciImage
{

    ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeRotation(-M_PI / 2.0)];
    CGPoint origin = ciImage.extent.origin;
    ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeTranslation(-origin.x, -origin.y)];
    
    if (_isFrontFacing) { // Y軸反転
        CGSize size = ciImage.extent.size;
        ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMake(-1.f, 0.f, 0.f, 1.f, size.width, 0.0)];
    }

    return ciImage;
}

- (CGFloat)rotationDegrees:(UIDeviceOrientation)orientation
{
    switch (orientation) {
		case UIDeviceOrientationPortrait:
			return -90.;
		case UIDeviceOrientationPortraitUpsideDown:
			return  90.;
		case UIDeviceOrientationLandscapeLeft:
			if (_isFrontFacing) return 180.;
			else return 0.;
		case UIDeviceOrientationLandscapeRight:
			if (_isFrontFacing) return 0.;
			else return 180.;
		case UIDeviceOrientationFaceUp:
		case UIDeviceOrientationFaceDown:
		default:
            return 0.;
	}
}

- (void)takePictureDone:(UIImage *)uiImage;
{
    [self stop];
    self.stillImageView.image = uiImage;
    [_controllTabBar moveControllToolbar:savePhotoToolBar];
}

#pragma mark - view utilities

- (void)setupOutputSize
{

    CGFloat xSCale = _previewView.width * 2.0 / _captureSize.width;
    CGFloat ySCale = _previewView.height * 2.0 / _captureSize.height;
    CGFloat scale = MIN(xSCale, ySCale);
    
    _outputSize.height = scale * _captureSize.height;
    _outputSize.width = scale * _captureSize.width;

    NSLog(@"%@", NSStringFromCGSize(_captureSize));
    NSLog(@"%@", NSStringFromCGSize(_outputSize));
    NSLog(@"%@", NSStringFromCGSize(_previewView.frame.size));
    NSLog(@"%f", scale);
}



#pragma mark - controll tool bar delegate
- (void)changeFilter:(DistControllToolBar *)toolBar
{
    if (_filterSelectionViewController) {
        [self hideFilterSelectionViewController];
    } else {
        [self showFilterSelectionViewController];
    }
}

- (void)hideFilterSelectionViewController
{
    [UIView animateWithDuration:0.25 animations:^{
        _filterSelectionViewController.view.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_filterSelectionViewController.view removeFromSuperview];
        self.filterSelectionViewController = nil;
    }];
}

- (void)showFilterSelectionViewController
{
    self.filterSelectionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DistFilterSelectionViewController"];
    _filterSelectionViewController.view.alpha = 0.f;
    [self.view addSubview:_filterSelectionViewController.view];
    [UIView animateWithDuration:0.25 animations:^{
        _filterSelectionViewController.view.alpha = 1.f;
    } completion:nil];
}

- (void)changeSetting:(DistControllToolBar *)toolBar
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

- (void)switchCamera:(DistControllToolBar *)toolBar
{
    AVCaptureDevicePosition desiredPosition;
	if (_isFrontFacing)
		desiredPosition = AVCaptureDevicePositionBack;
	else
		desiredPosition = AVCaptureDevicePositionFront;
	
	for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == desiredPosition) {
			[_session beginConfiguration];
			AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
			for (AVCaptureInput *oldInput in _session.inputs) {
				[_session removeInput:oldInput];
			}
			[_session addInput:input];
			[_session commitConfiguration];
			break;
		}
	}
    _isFrontFacing = !_isFrontFacing;
}

- (void)cancelSavePhoto:(DistControllToolBar *)toolBar
{
    [_controllTabBar moveControllToolbar:mainToolBar];
    [self start];
}

- (void)savePhoto:(DistControllToolBar *)toolBar
{
    [_controllTabBar moveControllToolbar:mainToolBar];
    [self start];
}

- (void)start
{
    self.stillImageView.image = nil;
    [_session startRunning];
}

- (void)stop
{
    [_session stopRunning];
}

@end
