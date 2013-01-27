//
//  DistControllToolBar.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/28.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "DistControllToolBar.h"

@interface DistControllToolBar ()
- (IBAction)filterButtonTapped:(id)sender;
- (IBAction)takePictureButtonTapped:(id)sender;
- (IBAction)switchCameraButtonTapped:(id)sender;
- (IBAction)settingButtonTapped:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *mainToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *savePhotoToolBar;
@property (strong, nonatomic) IBOutlet UIView *view;

@end

@implementation DistControllToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"DistControllToolBar" owner:self options:nil];
        [self addSubview:self.view];
        _scrollView.contentSize = CGSizeMake(640.0, 60.0);
        _mainToolBar.height = 60.0;
        _mainToolBar.top = 0.0;
        _savePhotoToolBar.height = 60.0;
        _savePhotoToolBar.top = 0.0;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:self.view];
}

- (void)moveControllToolbar:(DistToolBarType)targetToolBar
{
    CGPoint offset;
    
    if (targetToolBar == mainToolBar) offset = CGPointMake(0, 0);
    else if (targetToolBar == savePhotoToolBar) offset = CGPointMake(320, 0);
    else offset = CGPointMake(0, 0);

    [_scrollView setContentOffset:offset animated:YES];
}

#pragma mark action handlers

- (IBAction)filterButtonTapped:(id)sender {
    [_delegate changeFilter:self];
}

- (IBAction)takePictureButtonTapped:(id)sender {
    [_delegate takePicture:self];
}

- (IBAction)switchCameraButtonTapped:(id)sender {
    [_delegate switchCamera:self];
}

- (IBAction)settingButtonTapped:(id)sender {
    [_delegate changeSetting:self];
}

- (IBAction)cancelButtonTapped:(id)sender {
    [_delegate cancelSavePhoto:self];
}

- (IBAction)saveButtonTapped:(id)sender {
    [_delegate savePhoto:self];
}
@end
