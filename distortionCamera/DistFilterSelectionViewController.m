//
//  DistFilterSelectionViewController.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2013/02/05.
//  Copyright (c) 2013年 武田 祐一. All rights reserved.
//

#import "DistFilterSelectionViewController.h"
#import "DistFilterCell.h"

@interface DistFilterSelectionViewController ()
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UIImage *faceImage;
@property (nonatomic, strong) CIFaceFeature *faceFeature;
@end

static NSString *cellIdentifier = @"filterCell";

@implementation DistFilterSelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    UIImage *backgroundImage = [UIImage imageNamed:@"filter_popup.png"];
    _backgroundImageView.image = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 15, 40, 18)];

    [_collectionView registerClass:[DistFilterCell class] forCellWithReuseIdentifier:cellIdentifier];
    _collectionView.backgroundColor = [UIColor clearColor];

    self.faceImage = [UIImage imageNamed:@"face.png"];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyLow}];
    CIImage *ciImage = [CIImage imageWithCGImage:_faceImage.CGImage];
    self.faceFeature = [detector featuresInImage:ciImage][0];

}

- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}


#pragma mark uicollection view delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [DistFilter buildInFilters].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DistFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    NSDictionary *dict = [[DistFilter buildInFilters] objectAtIndex:indexPath.row];

    cell.filter = [[DistFilter alloc] initWithDict:dict];

    CIImage *ciImage = [CIImage imageWithCGImage:_faceImage.CGImage];
    [cell transformWithImage:ciImage faceFeature:_faceFeature];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = @{
    @"name" : @"bump_test",
    @"filters" : @[
    @{
    @"filterType" : @"CIBumpDistortion",
    @"inputs" : @{
    @"center" :  @"rightEye",
    @"radius" : @0.1,
    @"inputScale" : @0.7
    }
    },
    @{
    @"filterType" : @"CIBumpDistortion",
    @"inputs" : @{
    @"center" :  @"leftEye",
    @"radius" : @0.1,
    @"inputScale" : @0.7
    }
    },
    @{
    @"filterType" : @"CIBumpDistortion",
    @"inputs" : @{
    @"center" :  @"nose",
    @"radius" : @0.3,
    @"inputScale" : @-0.8
    }
    }

    ]
    };

    if ([_delegate respondsToSelector:@selector(filterSelected:)]) {
        [_delegate filterSelected:dict];
    }

}

@end
