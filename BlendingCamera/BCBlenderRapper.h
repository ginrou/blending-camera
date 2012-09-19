//
//  BCBlenderRapper.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/19.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#ifndef __BC_BLENDER_RAPPER__
#define __BC_BLENDER_RAPPER__

#import <Foundation/Foundation.h>
#include "BCImageConverter.h"
#include "Blender.h"

@interface BCBlenderRapper : NSObject
{

}

@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic, strong) UIImage *targetImage;
@property (nonatomic, strong) UIImage *mask;
@property (nonatomic, assign) CGPoint offset;

- (UIImage *)WrappedSeamlessClone:(bool)mixture;

@end

#endif