//
//  BCBlenderRapper.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/19.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCBlenderRapper.h"

@implementation BCBlenderRapper

- (UIImage *)WrappedSeamlessClone:(bool)mixture
{
	cv::Mat sourceMat = [BCImageConverter cvMatFromUIImage:_sourceImage];
	NSLog(@"source converted");
	cv::Mat targetMat = [BCImageConverter cvMatFromUIImage:_targetImage];
	NSLog(@"target converted");
	cv::Mat maskMat   = [BCImageConverter cvMatFromUIImage:_mask];
	NSLog(@"mask converted");
	
	Blend::PoissonBlender bld = Blend::PoissonBlender(sourceMat, targetMat, maskMat);
	cv::Mat dst;
	NSLog(@"blending start");
	bld.seamlessClone(dst, _offset.x, _offset.y, false);
	NSLog(@"blending done");
	return [BCImageConverter UIImageFromCVMat:dst];
}

@end
