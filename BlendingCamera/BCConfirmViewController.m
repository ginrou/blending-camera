//
//  BCConfirmViewController.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/21.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCConfirmViewController.h"

@interface BCConfirmViewController ()

@end

@implementation BCConfirmViewController
@synthesize imageView;

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
	imageView.image = _targetImage;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:
									  UIBarButtonItemStyleBordered
																	 target:self
																	 action:@selector(backButtonTapped)];
	self.navigationItem.leftBarButtonItem = leftBarButton;
	
	UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
																	   style:UIBarButtonItemStyleBordered
																	  target:self
																	  action:@selector(nextButtonTapped)];
	self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)nextButtonTapped
{
}

- (void)backButtonTapped
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
