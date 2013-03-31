//
//  DistFilterCell.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2013/02/10.
//  Copyright (c) 2013年 武田 祐一. All rights reserved.
//

#import "DistFilterCell.h"

@interface DistFilterCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *filterNameLabel;
@end

@implementation DistFilterCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)transformWithImage:(CIImage *)faceImage faceFeature:(CIFaceFeature *)feature
{

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.width)];

    _imageView.image = [DistFilter sampleImage:faceImage filter:_filter feature:feature];
    [self addSubview:_imageView];

    self.filterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _imageView.bottom+2, self.width, 13)];
    _filterNameLabel.font = [UIFont systemFontOfSize:12];
    _filterNameLabel.textAlignment = UITextAlignmentCenter;
    _filterNameLabel.text = _filter.name;

    _filterNameLabel.backgroundColor = [UIColor clearColor];

    [self addSubview:_filterNameLabel];

}

@end
