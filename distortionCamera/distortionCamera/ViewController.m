//
//  ViewController.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/17.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h>

@interface FaceViewController ()
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, strong) CIFilter *filter;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) CIContext *context;
@end

@implementation FaceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAVCaputre];
    [self setupImageProcessings];
    [[_videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    _imageView.backgroundColor = [UIColor blackColor];
    self.context = [CIContext contextWithOptions:nil];
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

    [_videoDataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCMPixelFormat_32BGRA]}];
    [_videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];

    // create a serial dispatch queue
    _videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

    [_session addOutput:_videoDataOutput];
    [[_videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
    [_session commitConfiguration];
    [_session startRunning];
}

- (void)setupImageProcessings
{
    self.filter = [CIFilter filterWithName:@"CIVignette"];
    [self.filter setValue:@1.0 forKey:@"inputIntensity"];
    [self.filter setValue:@2.0 forKey:@"inputRadius"];
}

#pragma mark -- processings
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // got an image
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeRotation(-M_PI / 2.0)];
    CGPoint origin = ciImage.extent.origin;
    ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeTranslation(-origin.x, -origin.y)];

    if (attachments)
        CFRelease(attachments);

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

    //NSDictionary *imageOption = @{CIDetectorImageOrientation : [NSNumber numberWithInt:exifOrientation]};
    //NSArray *features = [_faceDetector featuresInImage:ciImage options:imageOption];



//    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
//    CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false);

    dispatch_async(dispatch_get_main_queue(), ^{
        //[self drawFaceBoxesForFeatures:features forVideoBox:clap orientation:deviceOrientaion];
        [self.filter setValue:ciImage forKey:@"inputImage"];
        CGImageRef ref = [_context createCGImage:_filter.outputImage fromRect:CGRectMake(0, 0, 480, 640)];
        self.imageView.image = [UIImage imageWithCGImage:ref];
        [self.filter setValue:nil forKey:@"inputImage"];

    });
}

- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSLog(@"saved %@", error);
}

@end
