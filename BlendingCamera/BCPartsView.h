//
//  BCPartsView.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/11/07.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCPartsView : UIView
@property (nonatomic, strong) UIImage *image;
+(UIImage *)resizedImage:(UIImage *)image ForSize:(CGSize)size;
+(UIImage *)resizedGrayScaleImage:(UIImage *)image ForSize:(CGSize)size;

@end
