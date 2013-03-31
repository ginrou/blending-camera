//
//  DistControllToolBar.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/28.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "DistControllToolBar.h"
#import <QuartzCore/QuartzCore.h>

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
@property (strong, nonatomic) UIBarButtonItem *filterButton;
@end

static const CGFloat scrollBarHeight = 60;
static const CGFloat scrollBarButtonHeight = 45;
#define FlexibleSpaceBarButtonItem [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]

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
        NSMutableArray *items = [NSMutableArray array];

        self.filterButton = [[self class] customBarButtonItemWithImage:[UIImage imageNamed:@"face.png"]
                                                        highlitedImage:nil
                                                                target:self
                                                              selector:@selector(filterButtonTapped:)];

        UIBarButtonItem *takePictureButton = [[self class] customBarButtonItemWithImage:[UIImage imageNamed:@"take_picture"]
                                                                         highlitedImage:[UIImage imageNamed:@"take_picture_press"]
                                                                                 target:self
                                                                               selector:@selector(takePictureButtonTapped:)];

        UIBarButtonItem *switchCameraButton = [[self class] customBarButtonItemWithImage:[UIImage imageNamed:@"switch_camera"]
                                                                          highlitedImage:nil
                                                                                  target:self
                                                                                selector:@selector(switchCameraButtonTapped:)];


        [items addObject:_filterButton];
        [items addObject:FlexibleSpaceBarButtonItem];
        [items addObject:takePictureButton];
        [items addObject:FlexibleSpaceBarButtonItem];
        [items addObject:switchCameraButton];

        [_mainToolBar setItems:items animated:NO];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:self.view];
}

- (void)setupToolBar
{
}


+ (UIBarButtonItem *)customBarButtonItemWithImage:(UIImage *)image highlitedImage:(UIImage *)highlitedImage target:(id)target selector:(SEL)sender
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];

    if (highlitedImage) [button setImage:highlitedImage forState:UIControlStateHighlighted];

    CGFloat height = scrollBarButtonHeight;
    CGFloat width = (image.size.width / image.size.height) * height;
    button.frame = CGRectMake(0, 0, width, height);

    if (sender && target) [button addTarget:target action:sender forControlEvents:UIControlEventTouchUpInside];


    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)updateFilterImage:(DistFilter *)filter
{
    UIImage *faceImage = [UIImage imageNamed:@"face.png"];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyLow}];
    CIImage *ciImage = [CIImage imageWithCGImage:faceImage.CGImage];
    CIFaceFeature *feature = [detector featuresInImage:ciImage][0];
    UIImage *image = [DistFilter sampleImage:ciImage filter:filter feature:feature];
    UIButton *button = (UIButton *)_filterButton.customView;
    [button setImage:image forState:UIControlStateNormal];
}

#pragma mark - public methods
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
