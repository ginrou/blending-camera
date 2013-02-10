//
//  DistFilterCell.h
//  distortionCamera
//
//  Created by 武田 祐一 on 2013/02/10.
//  Copyright (c) 2013年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DistFilter.h"

@interface DistFilterCell : UICollectionViewCell

@property (nonatomic, strong) DistFilter *filter;
- (void)transformWithImage:(CIImage *)faceImage faceFeature:(CIFaceFeature *)feature;

@end
