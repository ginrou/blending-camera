//
//  BCPartsView.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/11/07.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCPartsView.h"

@interface BCPartsView ()
@property (nonatomic, assign) CGAffineTransform currentTransForm;
@end

@implementation BCPartsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:panGestureRecognizer];
 
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        [self addGestureRecognizer:pinchGestureRecognizer];
        
        self.userInteractionEnabled = YES;
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [_image drawInRect:self.bounds];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    const CGFloat dashStyle[] = {4.0};
    CGContextSetLineDash(context, 0.0, dashStyle, 1);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    CGPoint point = [sender translationInView:self.superview];
    CGPoint pointMoved = CGPointMake(self.center.x + point.x, self.center.y + point.y);
    self.center = pointMoved;
	NSLog(@"%@", NSStringFromCGPoint(pointMoved));
    [sender setTranslation:CGPointZero inView:self];
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        _currentTransForm = self.transform;
    }
    
    CGFloat scale = [sender scale];
    self.transform = CGAffineTransformConcat(_currentTransForm, CGAffineTransformMakeScale(scale, scale));
    
}

+(UIImage *)resizedImage:(UIImage *)image ForSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *dst = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return dst;
}

+(UIImage *)resizedGrayScaleImage:(UIImage *)image ForSize:(CGSize)size
{
    CGRect imageRect = CGRectMake(0, 0, size.width, size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, image.CGImage);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *dst = [UIImage imageWithCGImage:imageRef];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    return dst;
}

@end
