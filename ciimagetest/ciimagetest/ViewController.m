//
//  ViewController.m
//  ciimagetest
//
//  Created by 武田 祐一 on 2013/02/10.
//  Copyright (c) 2013年 武田 祐一. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIImage *image = [UIImage imageNamed:@"lenna.jpg"];
    CIImage *input = [CIImage imageWithCGImage:image.CGImage];

    CIFilter *filter = [CIFilter filterWithName:@"CIBumpDistortionLinear"];

    [filter setValue:input forKey:@"inputImage"];


    CIVector *center;
    center = [CIVector vectorWithCGPoint:CGPointMake(120, 50)];
    [filter setValue:center forKey:@"inputCenter"];

    CGFloat radius = 140.0f;
    [filter setValue:@2.0 forKey:@"inputScale"];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    CGFloat angle = M_PI / 2.0;
    [filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];

    [self cropRadius:filter center:center radius:radius imageSize:image.size];
    CIImage *output = filter.outputImage;

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCIImage:output]];
    [self.view addSubview:imageView];
    imageView.backgroundColor = [UIColor redColor];

    NSLog(@"%@", NSStringFromCGSize([[UIImage imageWithCIImage:output] size]));
    NSLog(@"%@", imageView);
}

- (void)cropRadius:(CIFilter *)filter center:(CIVector *)center radius:(CGFloat)radius imageSize:(CGSize)size
{
    CGFloat left = center.X - radius;
    CGFloat top = center.Y - radius;
    CGFloat bottom = center.Y + radius - size.height;
    CGFloat right = center.X + radius - size.width;

    NSLog(@"%f, %f %f, %f", left, top, bottom, right);

    if (left >= 0 && top >= 0 && bottom >= 0 && right >= 0) return;

    CGFloat max = MAX(left, MAX(top, MAX(bottom, right)));
    CGFloat newRadius = 0.0;

    if (max == left || max == right) newRadius = size.width/2.0;
    else  newRadius = size.height/2.0; // max == top || max == bottom

    if (max == left) newRadius = center.X;
    else if (max == top) newRadius = center.Y;
    else if (max == right) newRadius = size.width - center.X;
    else newRadius = size.height - center.Y;  // max == bottom

    NSLog(@"%f, %f", max, newRadius);

    [filter setValue:[NSNumber numberWithFloat:newRadius] forKey:@"inputRadius"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
