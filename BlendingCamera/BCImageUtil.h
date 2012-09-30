//
//  BCImageUtil.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 12/09/30.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <opencv2/opencv.hpp>

@interface BCImageUtil : NSObject

+ (UIImage *)cutoffPartsRegion:(UIImage *)image;

@end