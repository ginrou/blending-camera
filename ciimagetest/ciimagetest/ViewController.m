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

    [filter setValue:@2.0 forKey:@"inputScale"];
    [filter setValue:@40 forKey:@"inputRadius"];
    CGFloat angle = M_PI / 2.0;
    [filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];

    CIImage *output = filter.outputImage;
    NSLog(@"%@", filter);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCIImage:output]];
    [self.view addSubview:imageView];
    imageView.backgroundColor = [UIColor redColor];

    NSLog(@"%@", NSStringFromCGSize([[UIImage imageWithCIImage:output] size]));
    NSLog(@"%@", imageView);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
