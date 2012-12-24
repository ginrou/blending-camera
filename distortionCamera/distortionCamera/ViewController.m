//
//  ViewController.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/17.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h>
#import <GLKit/GLKit.h>

@interface FaceViewController ()
{

}
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, strong) CIFilter *filter;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) EAGLContext *eaglContext;
@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, assign) GLuint defaultFrameBuffer;
@property (nonatomic, assign) GLuint colorRenderBuffer;
@property (nonatomic, assign) CGSize captureSize;
@property (nonatomic, assign) CGSize outputSize;
@end

@implementation FaceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAVCaputre];
    [self setupImageProcessings];
    [[_videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    [self setupGL];

    self.context = [CIContext contextWithEAGLContext:_eaglContext];
    [self setupOutputSize];
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

- (void)setupImageProcessings
{
    self.filter = [CIFilter filterWithName:@"CIHoleDistortion"];
    [_filter setDefaults];
    [_filter setValue:@20 forKey:@"inputRadius"];
//    [_filter setValue:@0.5 forKey:@"inputScale"];
//    [_filter setValue:@(-3.140/4.0) forKey:@"inputAngle"];

    NSDictionary *detectorOption = @{CIDetectorAccuracy : CIDetectorAccuracyLow, CIDetectorTracking : @YES};
    self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:_context options:detectorOption];
}

- (void)setupGL
{
    self.eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.glkView = [[GLKView alloc] initWithFrame:_previewView.frame context:_eaglContext];

    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)_glkView.layer;
    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @FALSE, kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};

    //_glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self.view addSubview:_glkView];

    glGenRenderbuffers(1, &_defaultFrameBuffer);
    glBindRenderbuffer(GL_FRAMEBUFFER, _defaultFrameBuffer);

    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);

    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);

    GLint width = _glkView.frame.size.width;
    GLint hegith = _glkView.frame.size.height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &hegith);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);

    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFrameBuffer);
    glViewport(0, 0, width, hegith);
    NSLog(@"%d, %d", width, hegith);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed To make complete frame buffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }

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
    NSArray *features = [_faceDetector featuresInImage:ciImage options:imageOption];

    for (CIFaceFeature *f in features) {
//        NSLog(@"%f, %f", f.bounds.size.width, f.bounds.size.height);
        [_filter setValue:[CIVector vectorWithCGPoint:[self center:f.bounds]] forKey:@"inputCenter"];
    }

//    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
//    CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false);

    [self.filter setValue:ciImage forKey:@"inputImage"];
    CIImage *outputCIImage = _filter.outputImage;
    outputCIImage = [outputCIImage imageByApplyingTransform:CGAffineTransformMakeRotation(-M_PI / 2.0)];
    CGPoint origin = outputCIImage.extent.origin;
    outputCIImage = [outputCIImage imageByApplyingTransform:CGAffineTransformMakeTranslation(-origin.x, -origin.y)];

    [_context drawImage:outputCIImage inRect:CGRectMake(0, 0, _outputSize.width, _outputSize.height) fromRect:CGRectMake(0, 0, 480, 640)];

    [EAGLContext setCurrentContext:_eaglContext];
    glBindFramebuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];

    dispatch_async(dispatch_get_main_queue(), ^{
        //[self drawFaceBoxesForFeatures:features forVideoBox:clap orientation:deviceOrientaion];

        static CGRect outputRect;
        static int first = 0;
        if (first++ == 0) {
            NSLog(@"mainscreen = %@", NSStringFromCGRect([[UIScreen mainScreen] applicationFrame]));
            NSLog(@"outputciimage = %@", NSStringFromCGRect(outputCIImage.extent));
            NSLog(@"glkview = %@", NSStringFromCGRect(_glkView.frame));

            outputRect.origin.x = 0;
            outputRect.origin.y = 0;
            outputRect.size.width = 480;
            outputRect.size.height = 640;
        }

        [self.filter setValue:nil forKey:@"inputImage"];

    });
}

- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSLog(@"saved %@", error);
}

#pragma mark - view utilities

- (void)setupOutputSize
{
    CGFloat maxWitdh = _glkView.frame.size.width * 2;
    CGFloat maxHeight = _glkView.frame.size.height * 2;

    CGFloat scale = ( maxHeight > maxWitdh) ? maxHeight / _captureSize.height : maxWitdh / _captureSize.width;

    _outputSize.height = scale * _captureSize.height;
    _outputSize.width = scale * _captureSize.width;

}

- (CGPoint)center:(CGRect)rect
{
    return CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
}

@end
