//
//  BCPathView.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/21.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BCPathViewDelegate;

@interface BCPathView : UIView

@property (nonatomic, assign) id<BCPathViewDelegate> delegate;
@property (nonatomic, assign) CGMutablePathRef currentPath;
@property (nonatomic, strong) CALayer *pathLayer;
@property (nonatomic, assign) CGContextRef bitmapCopntext;

- (void)clearPath;

//- (CGImage)cgImage;

+ (CGContextRef)newBlankBitmapContextOfSize:(CGSize)size;
+ (CGContextRef)newTransparentBitmapContextOfSize:(CGSize)size;

@end

@protocol BCPathViewDelegate <NSObject>

- (void)didPartsSelected:(BCPathView *)pathView andSelectedParts:(UIImage *)selectedParts;

@end