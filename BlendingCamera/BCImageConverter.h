//
//  BCImageConverter.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 12/09/17.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#ifndef __BC_IMAGE_CONVERTER__
#define __BC_IMAGE_CONVERTER__

#import <Foundation/Foundation.h>
#include <opencv2/opencv.hpp>

@interface BCImageConverter : NSObject
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromCVMat:(cv::Mat)mat;


@end

#endif