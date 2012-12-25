//
//  DistOptions.h
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/25.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DistOptions : NSObject

+ (void)saveDetectorAccuracy:(NSString *)accuracy;
+ (NSString *)loadDetectorAccuray;

+ (void)saveAutoIntensityCollection:(BOOL)enable;
+ (BOOL)loadAutoIntensityCollection;

+ (void)saveFlash:(BOOL)enable;
+ (BOOL)loadFlash;

@end
