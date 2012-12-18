//
//  ViewController.h
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/17.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CIDetector;

@interface FaceViewController : UIViewController
<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    dispatch_queue_t _videoDataOutputQueue;
}

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
