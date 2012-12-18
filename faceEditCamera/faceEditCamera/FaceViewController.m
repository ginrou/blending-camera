//
//  FaceViewController.m
//  faceEditCamera
//
//  Created by 武田 祐一 on 2012/11/26.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "FaceViewController.h"
#import <CoreImage/CoreImage.h>

@interface FaceViewController ()
@property (nonatomic, strong) CIFilter *filter;
@end

@implementation FaceViewController

- (void)setupAVCapture
{
    NSError *error = nil;
    AVCaptureSession *session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPreset640x480];

    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

    _isUsingFrontFacingCamera = NO;
    if ([session canAddInput:deviceInput])
        [session addInput:deviceInput];

    // make a still image output


    // make a video data output
    self.videoDataOutput = [AVCaptureVideoDataOutput new];

    [_videoDataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCMPixelFormat_32BGRA]}];
    [_videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];


    // create a serial dispatch queue
    _videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [_videoDataOutput setSampleBufferDelegate:self queue:_videoDataOutputQueue];

    if ([session canAddOutput:_videoDataOutput])
        [session addOutput:_videoDataOutput];
    [[_videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];

    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
//    [_previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
//    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
//    CALayer *rootLayer = [_previewView layer];
//    [rootLayer setMasksToBounds:YES];
//    [_previewLayer setFrame:[rootLayer bounds]];
//    [rootLayer addSublayer:_previewLayer];
    [session startRunning];

    // setup filter
    self.filter = [CIFilter filterWithName:@"CIVignette"];
    [_filter setValue:@1.0 forKey:@"inputIntensity"];
    [_filter setValue:@2.0 forKey:@"inputRadius"];
    //[self.previewView addSubview:_imageView];
    _imageView.image = [UIImage imageNamed:@"squarePNG.png"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAVCapture];
    self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyLow}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePicture:(id)sender
{

}

- (IBAction)switchCamera:(id)sender
{
    AVCaptureDevicePosition desiredPosition = _isUsingFrontFacingCamera ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;

    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (device.position == desiredPosition) {
            [_previewLayer.session beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            for (AVCaptureInput *oldInput in [[_previewLayer session] inputs]) {
                [_previewLayer.session removeInput:oldInput];
            }
            [_previewLayer.session addInput:input];
            [_previewLayer.session commitConfiguration];
            break;
        }
    }
    _isUsingFrontFacingCamera = !_isUsingFrontFacingCamera;
}

- (IBAction)toggleFaceDetection:(id)sender
{
    _detectFaces = [(UISwitch *)sender isOn];
    [[_videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:_detectFaces];
    if (_detectFaces) {
        dispatch_async(dispatch_get_main_queue(), ^{

        });
    }
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // got an image
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];

    [_filter setValue:ciImage forKey:@"inputImage"];
    UIImage *img = [UIImage imageWithCIImage:_filter.outputImage];
    [_filter setValue:nil forKey:@"inputImage"];
    NSLog(@"%@", img);
    _imageView.image = img;


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
			if (_isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (_isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}

    NSDictionary *imageOption = @{CIDetectorImageOrientation : [NSNumber numberWithInt:exifOrientation]};
    NSArray *features = [_faceDetector featuresInImage:ciImage options:imageOption];


    static int hoge = 0;
    if (hoge == 0) {

        UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        hoge++;
    }

    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self drawFaceBoxesForFeatures:features forVideoBox:clap orientation:deviceOrientaion];
    });
}


- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSLog(@"saved %@", error);
}
- (void)drawFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation
{
    for (CIFaceFeature *faceFeature in features) {
        NSLog(@"%@", NSStringFromCGRect(faceFeature.bounds));
    }
}
- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}
@end
