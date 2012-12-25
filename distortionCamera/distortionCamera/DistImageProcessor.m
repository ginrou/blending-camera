//
//  DistImageProcessor.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/26.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "DistImageProcessor.h"

#import "DistOptions.h"

@implementation DistImageProcessor

- (id)initWithEAGLContext:(EAGLContext *)eaglContext
{
    self = [super init];
    if (self) {
        self.ciContext = [CIContext contextWithEAGLContext:eaglContext];
        [self initializeFilter];
        [self setupFaceDetection];
        [self applyOptions];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyOptions) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

- (void)initializeFilter
{
    self.filter = [CIFilter filterWithName:@"CIBumpDistortion"];
    [_filter setDefaults];

}

- (void)setupFaceDetection
{
    NSString *accuracy = [DistOptions loadDetectorAccuray];
    NSDictionary *option = @{CIDetectorAccuracy : accuracy, CIDetectorTracking : @YES};
    self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:_ciContext options:option];
}


- (void)applyOptions
{
    if ([DistOptions loadAutoIntensityCollection]) {
        self.colorAdjustmentFilter = [CIFilter filterWithName:@"CIColorControls"];
        [_colorAdjustmentFilter setDefaults];
        [_colorAdjustmentFilter setValue:@1.0 forKey:@"inputSaturation"];
        [_colorAdjustmentFilter setValue:@0.01 forKey:@"inputBrightness"];
        [_colorAdjustmentFilter setValue:@1.0 forKey:@"inputContrast"];
    } else {
        self.colorAdjustmentFilter = nil;
    }

}

- (CIImage *)applyEffect:(CIImage *)srcImage options:(NSDictionary *)options
{
    NSArray *faceFeatures = [_faceDetector featuresInImage:srcImage options:options];
    CIImage *bufferImage = [srcImage copy];
    for (CIFaceFeature *f in faceFeatures) {
        [_filter setValue:bufferImage forKey:@"inputImage"];

        // bump distortion のみの特別処理
        // できれば [filter applyFaceFeature:f] とかですませたい
        CGFloat r = (f.bounds.size.height + f.bounds.size.width) * 0.2;
        [_filter setValue:[NSNumber numberWithFloat:r] forKey:@"inputRadius"];

        CGPoint center = CGPointMake(f.bounds.origin.x + f.bounds.size.width / 2.0,
                                     f.bounds.origin.y + f.bounds.size.height / 2.0);
        [_filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [_filter setValue:@(1.2) forKey:@"inputScale"];
        bufferImage = _filter.outputImage;

    }

    if (_colorAdjustmentFilter) {
        [_colorAdjustmentFilter setValue:bufferImage forKey:@"inputImage"];
        bufferImage = _colorAdjustmentFilter.outputImage;
    }

    [_filter setValue:nil forKey:@"inputImage"];
    return [bufferImage copy];

}

@end