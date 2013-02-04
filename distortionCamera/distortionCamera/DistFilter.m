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

#define kLeftEyeKey  @"leftEye"
#define kRightEyeKey @"rightEye"
#define kMouseKey    @"mouse"
#define kNoseKey     @"nose"

@implementation DistFilter

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

    CIVector *center = [self filterCenter:inputs[@"center"] feature:feature];
    [filter setValue:center forKey:@"inputCenter"];

    CGFloat scale = LENGTH(feature.bounds.size.width, feature.bounds.size.height);

    if (inputs[@"inputScale"]) [filter setValue:inputs[@"inputScale"] forKey:@"inputScale"];

    if (inputs[@"radius"]) {
        CGFloat radian = [inputs[@"radius"] floatValue] * scale;
        [filter setValue:[NSNumber numberWithFloat:radian] forKey:@"inputRadius"];
    }

    return filter.outputImage;
}

- (CIVector *)filterCenter:(NSString *)centerType feature:(CIFaceFeature *)feature
{
    if ([centerType isEqualToString:kLeftEyeKey])       return [CIVector vectorWithCGPoint:feature.leftEyePosition];
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


@end
