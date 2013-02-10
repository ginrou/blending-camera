//
//  DistFilterSelectionViewController.h
//  distortionCamera
//
//  Created by 武田 祐一 on 2013/02/05.
//  Copyright (c) 2013年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DistDistFilterSelectionDelegate;

@interface DistFilterSelectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) id<DistDistFilterSelectionDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@end

@protocol DistDistFilterSelectionDelegate <NSObject>
- (void) filterSelected:(NSDictionary *)filterDict;
@end
