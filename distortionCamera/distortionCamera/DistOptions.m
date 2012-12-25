//
//  DistOptions.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/25.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "DistOptions.h"

#define DetectorAccuracyKey @"detecotrAccuracy"
#define AutoIntentisyCollectionKey @"autoIntensityCollection"
#define FlashKey @"flashKey"

@implementation DistOptions

+ (void)saveDetectorAccuracy:(NSString *)accuracy
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:accuracy forKey:DetectorAccuracyKey];
    [userDefaults synchronize];
}

+ (NSString *)loadDetectorAccuray
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *accuarcy = [userDefaults objectForKey:DetectorAccuracyKey];
    return (accuarcy != nil) ? accuarcy : CIDetectorAccuracyLow;
}

+ (void)saveAutoIntensityCollection:(BOOL)enable
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:enable forKey:AutoIntentisyCollectionKey];
    [userDefaults synchronize];
}

+ (BOOL)loadAutoIntensityCollection
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:AutoIntentisyCollectionKey];
}

+ (void)saveFlash:(BOOL)enable
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:enable forKey:FlashKey];
    [userDefaults synchronize];
}

+ (BOOL)loadFlash
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:FlashKey];
}


@end
