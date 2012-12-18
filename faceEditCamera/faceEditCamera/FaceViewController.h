//
//  FaceViewController.h
//  faceEditCamera
//
//  Created by 武田 祐一 on 2012/11/26.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CIDetector;

@interface FaceViewController : UIViewController
<
UIGestureRecognizerDelegate,
AVCaptureVideoDataOutputSampleBufferDelegate
>
{
    dispatch_queue_t _videoDataOutputQueue;
}

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *cameraSelection;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureVideoDataOutput *videoDataOutput;
@property (assign, nonatomic) BOOL detectFaces;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) UIView *flashView;
@property (strong, nonatomic) UIImage *square;
@property (assign, nonatomic) BOOL isUsingFrontFacingCamera;
@property (strong, nonatomic) CIDetector *faceDetector;


@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)takePicture:(id)sender;
- (IBAction)switchCamera:(id)sender;
- (IBAction)toggleFaceDetection:(id)sender;

@end
