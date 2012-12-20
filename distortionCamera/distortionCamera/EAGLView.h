//
//  EAGLView.h
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/19.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface EAGLView : UIView
{
@private

    GLint frameBufferWidth;
    GLint frameBufferHeight;

    GLuint defaultFrameBuffer, colorRenderBuffer;
}

@property (nonatomic, strong) EAGLContext *context;

- (void)setFrameBuffer;
- (BOOL)presentFrameBuffer;

@end
