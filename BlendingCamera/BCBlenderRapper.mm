//
//  BCBlenderRapper.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/19.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCBlenderRapper.h"

@interface BCBlenderRapper ()
{
    cv::Mat sourceMat;
    cv::Mat targetMat;
    cv::Mat maskMat;
}

@end


@implementation BCBlenderRapper

- (void)dealloc
{
    sourceMat.release();
    targetMat.release();
    maskMat.release();
    self.sourceImage = nil;
    self.targetImage = nil;
    self.mask        = nil;
}


- (UIImage *)WrappedSeamlessClone:(bool)mixture
{
	sourceMat = [BCImageConverter cvMatFromUIImage:_sourceImage];
	NSLog(@"source converted");
	targetMat = [BCImageConverter cvMatFromUIImage:_targetImage];
	NSLog(@"target converted");
	maskMat   = [BCImageConverter cvMatFromUIImage:_mask];
	NSLog(@"mask converted");
	
    if (sourceMat.rows != maskMat.rows || sourceMat.cols != sourceMat.cols) {
        cv::Mat tmp(sourceMat.size(), maskMat.type());
        cv::resize(maskMat, tmp, sourceMat.size());
        maskMat.release();
        maskMat = tmp.clone();
        tmp.release();
    }
    
    [self addMergin];
    
	Blend::PoissonBlender bld = Blend::PoissonBlender(sourceMat, targetMat, maskMat);
	cv::Mat dst;
	NSLog(@"blending start");
	bld.seamlessClone(dst, _offset.x, _offset.y, false);
	NSLog(@"blending done");
	return [BCImageConverter UIImageFromCVMat:dst];
}

- (void)addMergin
{
    cv::Mat sourceTmp, maskTmp;
    cv::copyMakeBorder(sourceMat, sourceTmp, 2, 2, 2, 2, cv::BORDER_REPLICATE);
    sourceMat.release();
    sourceMat = sourceTmp.clone();
    cv::copyMakeBorder(maskMat, maskTmp, 2, 2, 2, 2, cv::BORDER_CONSTANT);
    maskMat.release();
    maskMat = maskTmp.clone();
    sourceTmp.release();
    maskTmp.release();
}



@end
