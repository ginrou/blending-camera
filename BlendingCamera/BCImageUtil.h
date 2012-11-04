//
//  BCImageUtil.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 12/09/30.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <opencv2/opencv.hpp>

@interface BCImageUtil : NSObject {
	
}

@property (nonatomic, strong) UIImage *pathImage;

- (id)initWithPathImage:(UIImage *)image;
- (UIImage *)cutoffPartsRegion;
- (CGRect)boundingBoxForImage;
- (UIImage *)cutoffedMask;
- (UIImage *)maskedOriginalImage:(UIImage *)originalImage;

+ (UIImage *)cutoffPartsRegion:(UIImage *)image;



@end
