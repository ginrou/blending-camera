//
//  BCImageConverter.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 12/09/17.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCImageConverter.h"

@implementation BCImageConverter

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
	
	CGBitmapInfo bitmapInfo;
	int matType;
	int channels = CGColorSpaceGetNumberOfComponents(colorSpace);
	if (channels == 1) {
		bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaNone;
		matType = CV_8UC1;
	} else if (channels == 3) {
		bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaNoneSkipLast;
		matType = CV_8UC4;
	} else if (channels == 4) {
		bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
		matType = CV_8UC4;
	}
	
	cv::Mat dst(rows, cols, matType);

	CGContextRef contextRef = CGBitmapContextCreate(dst.data, cols, rows, 8, dst.step[0], colorSpace, bitmapInfo);
	CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);

	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);
	
	if (channels == 3) {
		cv::Mat dst3ch(rows, cols, CV_8UC3);
		cv::cvtColor(dst, dst3ch, CV_RGBA2RGB);

		return dst3ch;
	}else {
		return dst;
	}

}

+ (UIImage *)UIImageFromCVMat:(cv::Mat)mat
{
	cv::Mat src;
	if (mat.channels() == 3) {
		cv::Mat mat_4ch( mat.rows, mat.cols, CV_8UC4);
		cv::cvtColor(mat, mat_4ch, CV_RGB2RGBA);
		src = mat_4ch;
	} else {
		src = mat;
	}
	
    NSData *data = [NSData dataWithBytes:src.data length:src.elemSize() * src.total()];
    CGColorSpaceRef colorSpace = (src.elemSize() == 1) ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(src.cols, src.rows, 8, 8 * src.elemSize(), src.step[0], colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    
    UIImage *uiImage = [UIImage imageWithCGImage:imageRef];
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return uiImage;
}

@end
