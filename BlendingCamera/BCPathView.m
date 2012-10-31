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
	self.pathLayer.delegate = self;
	[self drawCurrentPath:self.bitmapCopntext];
	[_pathLayer setNeedsDisplay];
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
/*
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

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
			UIImage *parts = [BCImageUtil cutoffPartsRegion:[UIImage imageWithCGImage:cgImage]];
			[self.delegate didPartsSelected:self andSelectedParts:parts];
		}

    }
}

- (void)cutOffParts {
	
	for (int h = 0; h < self.frame.size.height; ++h) {
		unsigned char *row_buf = (unsigned char *)(_bitmapData );
		int offset = self.frame.size.width * h;
		for (int w = 0; w < self.frame.size.width; ++w) {
			
			unsigned char r = row_buf[offset + w*4+0];
			unsigned char g = row_buf[offset + w*4+1];
			unsigned char b = row_buf[offset + w*4+2];
			unsigned char a = row_buf[offset + w*4+3];

			NSLog(@"%u, %u, %u, %u", r,g,b,a);

		}
	}
	
	
}


@end
