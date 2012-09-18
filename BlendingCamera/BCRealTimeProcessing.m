//
//  BCRealTimeProcessing.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/17.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCRealTimeProcessing.h"

@interface BCRealTimeProcessing ()

@end

@implementation BCRealTimeProcessing

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
