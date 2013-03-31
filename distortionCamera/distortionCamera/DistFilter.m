//
//  DistFilter.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2013/02/04.
//  Copyright (c) 2013年 武田 祐一. All rights reserved.
//

#import "DistFilter.h"
#define LENGTH(w,h) (sqrt((w)*(w) + (h) * (h) ))

@interface DistFilter ()
@property (nonatomic, strong) NSArray *requiredParts;
@end

#define kLeftEyeKey     @"leftEye"
#define kRightEyeKey    @"rightEye"
#define kMouseKey       @"mouse"
#define kNoseKey        @"nose"
#define kFaceCenterKey  @"center"

static NSArray *sharedBuildInFilters;
@implementation DistFilter
+ (NSArray *)buildInFilters
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"filter" ofType:@"plist"];
        sharedBuildInFilters = [NSArray arrayWithContentsOfFile:filePath];
    });
    return sharedBuildInFilters;
}

/* input format
 dict = {
    "name" : name_of_filter,
    "filters" : (
        {
            "filterType" : name_of_cifilter
            "inputs" : {
                center : qw|leftEye, rightEye, mouse, nose, ""|
                offset : offset from center
                and other values for filter
            }
        },
        {
            other filter definitions
        }
    )
 }
*/
- (id)initWithDict:(NSDictionary *)dict
{
    self = [self init];
    if (self) {
        self.name = dict[@"name"];
        NSMutableArray *array = [NSMutableArray array];
        NSMutableArray *requiredParts = [NSMutableArray array];
        for (NSDictionary *filterDict in dict[@"filters"]) {
            CIFilter *filter = [CIFilter filterWithName:filterDict[@"filterType"]];
            [filter setDefaults];
            [array addObject:@{@"filter": filter, @"inputs":filterDict[@"inputs"]}];
            [requiredParts addObject:filterDict[@"inputs"][@"center"]];
        }
        self.filters = [NSArray arrayWithArray:array];
        self.requiredParts = [NSArray arrayWithArray:requiredParts];
    }
    return self;
}

- (CIImage *)applyEffect:(CIImage *)image feature:(CIFaceFeature *)feature
{
    for (NSDictionary *filterDict in _filters) {
        image = [self applyFilter:filterDict image:image feature:feature];
    }
    return image;
}

- (BOOL)validateFeatures:(CIFaceFeature *)feature
{
    for (NSString *featureType in _requiredParts) {
        if ([featureType isEqualToString:kLeftEyeKey] && feature.hasLeftEyePosition == NO ) return NO;
        if ([featureType isEqualToString:kRightEyeKey] && feature.hasRightEyePosition == NO ) return NO;
        if ([featureType isEqualToString:kMouseKey] && feature.hasMouthPosition == NO ) return NO;
        if ([featureType isEqualToString:kNoseKey]  && (!feature.hasMouthPosition || !feature.hasRightEyePosition || !feature.hasMouthPosition)) return NO;
    }
    return YES;
}

- (CIImage *)applyFilter:(NSDictionary *)dict image:(CIImage *)image feature:(CIFaceFeature *)feature
{
    CIFilter *filter = dict[@"filter"];
    [filter setValue:image forKey:@"inputImage"];

    NSDictionary *inputs = dict[@"inputs"];
    CGFloat scale = LENGTH(feature.bounds.size.width, feature.bounds.size.height);

    CIVector *center = [self filterCenter:inputs[@"center"] feature:feature];
    if (inputs[@"offset"]) {
        CGPoint offset = CGPointMake([inputs[@"offset"][@"x"] floatValue], [inputs[@"offset"][@"y"] floatValue]);
        CIVector *offsetCenter = [self offsetFilterCenter:center offset:offset scale:scale];
        center = offsetCenter;
    }

    [filter setValue:center forKey:@"inputCenter"];


    if (inputs[@"inputScale"]) [filter setValue:inputs[@"inputScale"] forKey:@"inputScale"];
    if (inputs[@"inputAngle"]) [filter setValue:inputs[@"inputAngle"] forKey:@"inputAngle"];
    if (inputs[@"radius"]) {
        CGFloat radian = [inputs[@"radius"] floatValue] * scale;
        [filter setValue:[NSNumber numberWithFloat:radian] forKey:@"inputRadius"];
        [self cropRadius:filter center:center radius:radian imageSize:image.extent.size];
    }



    return filter.outputImage;
}

- (CIVector *)filterCenter:(NSString *)centerType feature:(CIFaceFeature *)feature
{
    if ([centerType isEqualToString:kFaceCenterKey]) {
        CGRect bounds = feature.bounds;
        CGPoint center = CGPointMake(bounds.origin.x + bounds.size.width / 2.0, bounds.origin.y + bounds.size.height / 2.0);
        return [CIVector vectorWithCGPoint:center];
    }
    else if ([centerType isEqualToString:kLeftEyeKey])       return [CIVector vectorWithCGPoint:feature.leftEyePosition];
    else if ([centerType isEqualToString:kRightEyeKey]) return [CIVector vectorWithCGPoint:feature.rightEyePosition];
    else if ([centerType isEqualToString:kMouseKey])    return [CIVector vectorWithCGPoint:feature.mouthPosition];
    else if ([centerType isEqualToString:kNoseKey]) {

        CGPoint leftEye = feature.leftEyePosition;
        CGPoint rightEye = feature.rightEyePosition;
        CGPoint mouse = feature.mouthPosition;
        CGPoint nose;
        nose.x = ((leftEye.x + rightEye.x ) / 2.0  + mouse.x ) / 2.0;
        nose.y = ((leftEye.y + rightEye.y ) / 2.0  + mouse.y ) / 2.0;
        return [CIVector vectorWithCGPoint:nose];

    } else {

        CGPoint faceCenter;
        faceCenter.x = feature.bounds.origin.x + feature.bounds.size.width / 2.0;
        faceCenter.y = feature.bounds.origin.y + feature.bounds.size.height / 2.0;
        return [CIVector vectorWithCGPoint:faceCenter];

    }
}

- (CIVector *)offsetFilterCenter:(CIVector *)center offset:(CGPoint)offset scale:(CGFloat)scale
{
    CGPoint offsetCenter;
    offsetCenter.x = center.X + offset.x * scale;
    offsetCenter.y = center.Y + offset.y * scale;
    return [CIVector vectorWithCGPoint:offsetCenter];
}

- (void)cropRadius:(CIFilter *)filter center:(CIVector *)center radius:(CGFloat)radius imageSize:(CGSize)size
{
    CGFloat left = center.X - radius;
    CGFloat top = center.Y - radius;
    CGFloat bottom = size.height - center.Y - radius;
    CGFloat right = size.width - center.X - radius;

    if (left >= 0 && top >= 0 && bottom >= 0 && right >= 0) return;

    CGFloat max = MAX(left, MAX(top, MAX(bottom, right)));
    CGFloat newRadius = 0.0;

    if (max == left) newRadius = center.X;
    else if (max == top) newRadius = center.Y;
    else if (max == right) newRadius = size.width - center.X;
    else newRadius = size.height - center.Y;  // max == bottom

    [filter setValue:[NSNumber numberWithFloat:newRadius] forKey:@"inputRadius"];

//    NSLog(@"%f, %f, %f, %f", left, top, bottom, right);
//    NSLog(@"(%f, %f), %@ : %f -> %f", center.X, center.Y, NSStringFromCGSize(size),radius, newRadius);

}


+ (UIImage *)sampleImage:(CIImage *)faceImage filter:(DistFilter *)filter  feature:(CIFaceFeature *)feature
{
    CIImage *preTransformedImage = [DistFilter preTransformedImage:faceImage];
    CIImage *filteredImage = [filter applyEffect:preTransformedImage feature:feature];
    CIImage *outputImage = [DistFilter setbackPreTransform:filteredImage];
    return [UIImage imageWithCIImage:outputImage];
}


+ (CIImage *)preTransformedImage:(CIImage *)ciImage
{
    ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeRotation(-M_PI / 2.0)];
    CGPoint origin = ciImage.extent.origin;
    ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeTranslation(-origin.x, -origin.y)];

    return ciImage;
}

+ (CIImage *)setbackPreTransform:(CIImage *)ciImage
{
    ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeRotation(M_PI / 2.0)];
    CGPoint origin = ciImage.extent.origin;
    ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeTranslation(-origin.x, -origin.y)];

    return ciImage;
}

@end
