//
//  BCRealTimeProcessingViewController.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/17.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
using namespace cv;


@interface BCRealTimeProcessingViewController : UIViewController
<CvVideoCameraDelegate>
{
	cv::Mat *previousMat;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) CvVideoCamera *videoCamera;

- (IBAction)buttonTapped:(id)sender;

@end
