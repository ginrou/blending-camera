//
//  DistFilterSelectionViewController.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2013/02/05.
//  Copyright (c) 2013年 武田 祐一. All rights reserved.
//

#import "DistFilterSelectionViewController.h"

@interface DistFilterSelectionViewController ()
@end

@implementation DistFilterSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    UIImage *backgroundImage = [UIImage imageNamed:@"00357_4.png"];
    _backgroundImageView.image = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(100, 0, 250, 584)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}
@end
