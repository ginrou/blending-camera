//
//  DistUtil.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2013/03/24.
//  Copyright (c) 2013年 武田 祐一. All rights reserved.
//

#import "DistUtil.h"

@implementation DistUtil

+ (UIImage *)convertBitmapformatBGRA2Default:(UIImage *)src
{
    CGDataProviderRef srcDataProvider = CGImageGetDataProvider(src.CGImage);
    CFDataRef srcDataRef = CGDataProviderCopyData(srcDataProvider);

    size_t bytesPerPixel = CGImageGetBitsPerPixel(src.CGImage) / sizeof(UInt8);
    unsigned int length = CFDataGetLength(srcDataRef);

    UInt8 *pixel = (UInt8 *)CFDataGetBytePtr(srcDataRef);
    for (int i = 0 ; i  < length; i += bytesPerPixel) {
        UInt8 *buf = pixel + i * bytesPerPixel;
        UInt8 r,g,b;

        // rgb
        r = buf[0];
        g = buf[1];
        b = buf[2];

        // bgr
        buf[0] = b;
        buf[1] = g;
        buf[2] = r;
    }

    CFDataRef dst = CFDataCreate(NULL, pixel, length);
    CGDataProviderRef dstDataProvider = CGDataProviderCreateWithCFData(dst);
    CGImageRef dstImage = CGImageCreate(src.size.width, src.size.height, CGImageGetBitsPerComponent(src.CGImage), CGImageGetBitsPerPixel(src.CGImage), CGImageGetBytesPerRow(src.CGImage), CGColorSpaceCreateDeviceRGB(), CGImageGetBitmapInfo(src.CGImage), dstDataProvider, NULL, CGImageGetShouldInterpolate(src.CGImage), CGImageGetRenderingIntent(src.CGImage));


    UIImage *ret = [UIImage imageWithCGImage:dstImage];
    return ret;

}

@end
