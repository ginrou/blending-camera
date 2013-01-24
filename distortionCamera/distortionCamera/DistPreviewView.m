//
//  DistPreviewView.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/25.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "DistPreviewView.h"
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>

@interface DistPreviewView ()
@property (nonatomic, assign) GLuint defaultFrameBuffer;
@property (nonatomic, assign) GLuint colorRenderBuffer;
@end

@implementation DistPreviewView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupWithFrame:(CGRect)frame error:(NSError *__autoreleasing *)error
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    [EAGLContext setCurrentContext:self.context];
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @FALSE, kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};

    glGenFramebuffers(1, &_defaultFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFrameBuffer);

    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);

    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];

    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);

    GLint width = self.width;
    GLint hegith = self.height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &hegith);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);


    glViewport(0, 0, width, hegith);
    NSLog(@"%d, %d", width, hegith);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed To make complete frame buffer object %d", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }

}

- (void)updateView
{
    [EAGLContext setCurrentContext:self.context];
    glViewport(0, 0, self.width, self.height);
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFrameBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}



@end
