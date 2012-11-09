//
//  BCPathView.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/21.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCPathView.h"
#import <QuartzCore/QuartzCore.h>
#import "BCImageUtil.h"

#define PATH_TH 50.0

@interface BCPathView ()
@property (nonatomic, assign) CGPoint previousPoint;
@property (nonatomic, assign) CGPoint pointDif;
@property (nonatomic, assign) void *bitmapData;
@end

@implementation BCPathView
static const CGFloat penColor[] = {1.0, 1.0, 1.0, 1.0}; // RGBA
static const CGFloat penWidth = 5.0;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
		self.pathLayer = [CALayer layer];
		self.pathLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
		[self.layer addSublayer:self.pathLayer];
        [self initPath];
		self.isAlreadyPicked = NO;
    }
    return self;
}

- (void)initPath
{
    self.bitmapCopntext = [self newTransparentBitmapContextOfSize:self.frame.size];
    CGContextRetain(self.bitmapCopntext);
    self.currentPath = CGPathCreateMutable();
    _pointDif.x = 0.0;
    _pointDif.y = 0.0;
}

- (void) dealloc
{
    [_pathLayer removeFromSuperlayer];
    self.pathLayer = nil;
    CGContextRelease(self.bitmapCopntext);
    CGPathRelease(self.currentPath);
}

- (void) setOriginalImage:(UIImage *)originalImage
{
    if (originalImage) {
        UIGraphicsBeginImageContext(self.frame.size);
        [originalImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _originalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}


#pragma mark utility methods
- (CGContextRef)newBlankBitmapContextOfSize:(CGSize)size
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	int bytesPerRow = (int)size.width * 4; // 4 means channel
	void *buf = malloc(bytesPerRow * (int)size.height);
	
	CGContextRef context = CGBitmapContextCreate(buf, size.width, size.height, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease(colorSpace);
	return context;
}

- (CGContextRef)newTransparentBitmapContextOfSize:(CGSize)size
{
	CGContextRef context = [self newBlankBitmapContextOfSize:size];
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
	CGContextTranslateCTM(context, 0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	return context;
}

#pragma mark -- touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint point = [((UITouch *)[touches anyObject]) locationInView:self];
	if (CGPathIsEmpty(_currentPath)) {
		CGPathMoveToPoint(self.currentPath, NULL, point.x, point.y);
		[self initializeCurve:point];
	} else {
		CGPathAddLineToPoint(self.currentPath, nil, point.x, point.y);
		[self closedCurve:point];
	}

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint point = [((UITouch *)[touches anyObject]) locationInView:self];
	CGPathAddLineToPoint(self.currentPath, nil, point.x, point.y);
    _pathLayer.delegate = self;
	[_pathLayer setNeedsDisplay];

	[self drawCurrentPath:self.bitmapCopntext];

	[self closedCurve:point];
    
    if ([self isCurveClosed])
        [self didPathSelected];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint point = [((UITouch *)[touches anyObject]) locationInView:self];
	CGPathAddLineToPoint(self.currentPath, nil, point.x, point.y);
	[self drawCurrentPath:self.bitmapCopntext];
	[self closedCurve:point];
    
    if ([self isCurveClosed])
        [self didPathSelected];
    
}

#pragma mark -- calcuration
- (void)closedCurve:(CGPoint)currentPoint
{
	_pointDif.x += currentPoint.x - _previousPoint.x;
	_pointDif.y += currentPoint.y - _previousPoint.y;
	//NSLog(@"previous = %.3f, .%.3f, current = %.3f, %.3f, diff= %.3f, %.3f", _previousPoint.x, _previousPoint.y, currentPoint.x, currentPoint.y, _pointDif.x, _pointDif.y);
	self.previousPoint = currentPoint;
}

- (void)initializeCurve:(CGPoint)firstPoint
{
	self.previousPoint = firstPoint;
}

- (BOOL)isCurveClosed
{
	CGFloat distance = _pointDif.x * _pointDif.x +_pointDif.y * _pointDif.y;
	//NSLog(@"distance = %f", distance);
	return (distance < PATH_TH ) ? YES : NO;
}


#pragma mark -- drawings

//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//
//}
//

- (void)drawCurrentPath:(CGContextRef)context
{
	if (self.currentPath != nil) {
		CGContextSetStrokeColor(context, penColor);
		CGContextBeginPath(context);
		CGContextAddPath(context, self.currentPath);
		CGContextSetLineWidth(context, penWidth);
		CGContextSetLineCap(context, kCGLineCapRound);
		CGContextSetLineJoin(context, kCGLineJoinRound);
		CGContextStrokePath(context);
	}
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	[self drawCurrentPath:ctx];
    if (layer == _pathLayer) {
        _pathLayer.delegate = nil;
    }
}

- (void)clearPath
{
    CGPathRelease(self.currentPath);
    CGContextRelease(self.bitmapCopntext);
    [self initPath];
    [_pathLayer setNeedsDisplay];
}


#pragma mark controlles
- (void)didPathSelected
{
    if ([self.delegate respondsToSelector:@selector(didPartsSelected:andSelectedParts:)]) {
		
        CGImageRef cgImage = CGBitmapContextCreateImage(self.bitmapCopntext);
        
		if (_isAlreadyPicked == NO && [_delegate respondsToSelector:@selector(didPartsSelected:andSelectedParts:)]) {
			self.isAlreadyPicked = YES;
            BCImageUtil *util = [[BCImageUtil alloc] initWithPathImage:[UIImage imageWithCGImage:cgImage]];
            CGRect boundingBox = [util boundingBoxForImage];
            UIImage *mask = [util cutoffedMask];
            UIImage *parts = [util maskedOriginalImage:_originalImage];
            
			[self.delegate didPartsSelected:self andSelectedParts:parts maskImage:mask];
		}

    }
}

@end
