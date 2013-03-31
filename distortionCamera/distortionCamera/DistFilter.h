//
//  DistFilter.h
//  distortionCamera
//
//  Created by 武田 祐一 on 2013/02/04.
//  Copyright (c) 2013年 武田 祐一. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DistFilter : NSObject

+ (NSArray *)buildInFilters;


@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *filters;

- (id)initWithDict:(NSDictionary *)dict;
- (CIImage *)applyEffect:(CIImage *)image feature:(CIFaceFeature *)feature;
+ (UIImage *)sampleImage:(CIImage *)faceImage filter:(DistFilter *)filter  feature:(CIFaceFeature *)feature;

@end
