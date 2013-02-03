//
//  DistFilter.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2013/02/04.
//  Copyright (c) 2013年 武田 祐一. All rights reserved.
//

#import "DistFilter.h"
#define LENGTH(w,h) (sqrt((w)*(w) + (h) * (h) ))

@implementation DistFilter

- (id)initWithDict:(NSDictionary *)dict
{
    self = [self init];
    if (self) {
        self.name = dict[@"name"];
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *filterDict in dict[@"filters"]) {
            CIFilter *filter = [CIFilter filterWithName:filterDict[@"name"]];
            [filter setDefaults];
            [array addObject:@{@"filter": filter, @"inputs":filterDict[@"inputs"]}];

        }
        self.filters = [NSArray arrayWithArray:array];
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

- (CIImage *)applyFilter:(NSDictionary *)dict image:(CIImage *)image feature:(CIFaceFeature *)feature
{
    CIFilter *filter = dict[@"filter"];
    [filter setValue:image forKey:@"inputImage"];

    NSDictionary *inputs = dict[@"inputs"];

    CIVector *center = [self filterCenter:inputs[@"center"] feature:feature];
    [filter setValue:center forKey:@"inputCenter"];

    CGFloat scale = LENGTH(feature.bounds.size.width, feature.bounds.size.height);

    if (inputs[@"inputScale"]) [feature setValue:inputs[@"inputScale"] forKey:inputs[@"inputScale"]];

    if (inputs[@"radius"]) {
        CGFloat radian = [inputs[@"radius"] floatValue] * scale;
        [feature setValue:[NSNumber numberWithFloat:radian] forKey:@"inputRadius"];
    }

    return filter.outputImage;
}

- (CIVector *)filterCenter:(NSString *)centerType feature:(CIFaceFeature *)feature
{
    if ([centerType isEqualToString:@"leftEye"])       return [CIVector vectorWithCGPoint:feature.leftEyePosition];
    else if ([centerType isEqualToString:@"rightEye"]) return [CIVector vectorWithCGPoint:feature.rightEyePosition];
    else if ([centerType isEqualToString:@"mouse"])    return [CIVector vectorWithCGPoint:feature.mouthPosition];
    else if ([centerType isEqualToString:@"nose"]) {

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
