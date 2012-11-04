//
//  BCImageUtil.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 12/09/30.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCImageUtil.h"
#import "BCImageConverter.h"

@interface BCImageUtil ()
{
	cv::Mat _pathMat;
	cv::Rect _boundingBox;
	cv::Mat _mask;
}

@end

@implementation BCImageUtil

- (id)initWithPathImage:(UIImage *)image
{
	self = [super init];
	if (self) {
		self.pathImage = image;
		_pathMat = [BCImageConverter cvMatFromUIImage:_pathImage];
		
	}
	return self;
}

- (void)dealloc
{
	_pathMat.release();
	self.pathImage = nil;
}

- (CGRect)boundingBoxForImage
{
	_boundingBox = getBoundingBox(_pathMat);
	return CGRectMake(_boundingBox.x, _boundingBox.y, _boundingBox.width, _boundingBox.height);
}

- (UIImage *)cutoffedMask
{
	_mask = fillInside(_pathMat, _boundingBox);
	return [BCImageConverter UIImageFromCVMat:_mask];
}

- (UIImage *)maskedOriginalImage:(UIImage *)originalImage
{
	cv::Mat orig = [BCImageConverter cvMatFromUIImage:originalImage];
	cv::Mat dst( _boundingBox.size(), CV_8UC4);
	
	
	
	
	UIImage *ret = [BCImageConverter UIImageFromCVMat:dst];
	dst.release();
	orig.release();
	return ret;
}


+ (UIImage *)cutoffPartsRegion:(UIImage *)image
{
    cv::Mat lineSrc = [BCImageConverter cvMatFromUIImage:image];
    
    NSLog(@"size = %d, %d, channels = %d", lineSrc.rows, lineSrc.cols, lineSrc.channels());
    
    cv::Rect boundigBox = getBoundingBox(lineSrc);
    NSLog(@"offset = %d, %d", boundigBox.x, boundigBox.y);
    NSLog(@"size = %d, %d", boundigBox.width, boundigBox.height);

    cv::Mat dst = fillInside(lineSrc, boundigBox);
    UIImage *ret = [BCImageConverter UIImageFromCVMat:dst];

    cv::Mat cropped = lineSrc(boundigBox);
    NSLog(@"%d, %d", lineSrc.rows, lineSrc.cols);
    //ret = [BCImageConverter UIImageFromCVMat:cropped];

    lineSrc.release();
    dst.release();

    
    return ret;
}


cv::Rect getBoundingBox(cv::Mat src)
{
    cv::Point offset(src.rows, src.cols), cutoff(0, 0);
    int chanels = src.channels();
    for (int h = 0; h < src.rows; ++h) {
        unsigned char *buf = src.ptr<unsigned char>(h);
        for (int w = 0; w < src.cols; ++w) {
            unsigned char r = buf[w*chanels + 0];
            unsigned char g = buf[w*chanels + 1];
            unsigned char b = buf[w*chanels + 2];

            if (r + g+b > 0) {
                
                if (h < offset.y ) offset.y = h;
                if (w < offset.x ) offset.x = w;
                
                if (h > cutoff.y ) cutoff.y = h;
                if (w > cutoff.x ) cutoff.x = w;
                
            }

        }
    }

    cv::Rect ret;
    ret.x = offset.x;
    ret.y = offset.y;
    ret.width = cutoff.x - offset.x;
    ret.height = cutoff.y - offset.y;
    return ret;

}

cv::Mat fillInside(cv::Mat img, cv::Rect boundingBox)
{
    cv::Mat dst(boundingBox.size(), CV_8UC1);
    
    bool isInside;

    for (int h = 0; h < boundingBox.height; ++h) {
        unsigned char *dst_buf = dst.ptr<unsigned char>(h);
        unsigned char *src_buf = img.ptr<unsigned char>(h+boundingBox.y);

        isInside = false;

        for (int w = 0; w < boundingBox.width; ++w) {
            
            int src_w_idx = ( w + boundingBox.x) * 3;
			int src_w_idx_prev = (w - 1 + boundingBox.x ) * 3;
            unsigned char srcSum = src_buf[src_w_idx+0] + src_buf[src_w_idx+1] + src_buf[src_w_idx+2];
			unsigned char srcSum_prev = src_buf[src_w_idx_prev+0] + src_buf[src_w_idx_prev+1] + src_buf[src_w_idx_prev+2];
            if (srcSum > 0  && srcSum_prev == 0) isInside = !isInside;

            dst_buf[w] = isInside ? 255 : 0;
            
        }
        
		// 一番上と一番下の行のための処理
		// 最後の列が内側の場合は，その行全体を黒にする
		if (dst_buf[boundingBox.width-1] != 0) {
			for (int w = 0; w < boundingBox.width; ++w) dst_buf[w] = 0;
		}
		
    }
    
    return dst;
}

@end
