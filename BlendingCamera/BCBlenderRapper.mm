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
//	cv::Mat sourceMat = [BCImageConverter cvMatFromUIImage:_sourceImage];
//	cv::Mat targetMat = [BCImageConverter cvMatFromUIImage:_targetImage];
//	cv::Mat maskMat   = [BCImageConverter cvMatFromUIImage:_mask];
//	blender = Blend::PoissonBlender(sourceMat, targetMat, maskMat);
//
//	cv::Mat dstMat;
//	blender.seamlessClone(dstMat, _offset.x, _offset.y, mixture);
//	return [BCImageConverter UIImageFromCVMat:dstMat];
	

	Blend::PoissonBlender bld = Blend::PoissonBlender();
	
	return nil;
}

@end
