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
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat mat(rows, cols, CV_8UC4);

    CGContextRef contextRef = CGBitmapContextCreate(mat.data, cols, rows, 8, mat.step[0], colorSpace, bitmapInfo);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    return mat;
}

+ (UIImage *)UIImageFromCVMat:(cv::Mat)mat
{
    NSData *data = [NSData dataWithBytes:mat.data length:mat.elemSize() * mat.total()];
    CGColorSpaceRef colorSpace = (mat.elemSize() == 1) ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(mat.cols, mat.rows, 8, 8 * mat.elemSize(), mat.step[0], colorSpace, kCGImageAlphaNone | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    
    UIImage *uiImage = [UIImage imageWithCGImage:imageRef];
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return uiImage;
}

@end
