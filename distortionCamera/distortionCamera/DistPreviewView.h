//
//  DistPreviewView.h
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/25.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface DistPreviewView : GLKView
- (void)setupWithFrame:(CGRect)frame error:(NSError **)error;
- (void)updateView;
@end
