//
//  EAGLView.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/19.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "EAGLView.h"
#import <QuartzCore/QuartzCore.h>

@implementation EAGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @FALSE, kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
    }
    return self;
}

- (void)dealloc
{
    [self deleteFrameBuffer];
}


- (void)setContext:(EAGLContext *)aContext
{
    if (_context != aContext) {
        [self deleteFrameBuffer];
        _context = aContext;
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)createFrameBuffer
{
    if (_context && !defaultFrameBuffer) {
        [EAGLContext setCurrentContext:_context];

        // create default frame buffer object;
        glGenFramebuffers(1, &defaultFrameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFrameBuffer);

        // create color render buffer and allocate backing store
        glGenRenderbuffers(1, &colorRenderBuffer);
        glBindFramebuffer(GL_RENDERBUFFER, colorRenderBuffer);

        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &frameBufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &frameBufferHeight);

        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);

        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Failed to make complete frame buffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        }

    }
}

- (void)deleteFrameBuffer
{
    if (_context) {
        [EAGLContext setCurrentContext:_context];
        if (defaultFrameBuffer) {
            glDeleteFramebuffers(1, &defaultFrameBuffer);
            defaultFrameBuffer = 0;
        }
        if (colorRenderBuffer) {
            glDeleteFramebuffers(1, &colorRenderBuffer);
            colorRenderBuffer = 0;
        }
    }
}

- (void)setFrameBuffer
{
    if (_context) {
        [EAGLContext setCurrentContext:_context];
        if (!defaultFrameBuffer) [self createFrameBuffer];

        glBindFramebuffer(GL_FRAMEBUFFER, defaultFrameBuffer);
        glViewport(0, 0, frameBufferWidth, frameBufferHeight);

    }
}

- (BOOL)presentFrameBuffer
{
    BOOL success = FALSE;
    if (_context) {
        [EAGLContext setCurrentContext:_context];
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
        success = [_context presentRenderbuffer:GL_RENDERBUFFER];
    }
    return success;
}

- (void)layoutSubviews
{
    [self deleteFrameBuffer];
}

@end
