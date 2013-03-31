//
//  DistControllToolBar.h
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/28.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DistFilter.h"

@protocol DistControllToolBarDelegate;

typedef enum {
    mainToolBar,
    savePhotoToolBar
}DistToolBarType;

@interface DistControllToolBar : UIView
@property (nonatomic, weak) id<DistControllToolBarDelegate> delegate;
- (void)moveControllToolbar:(DistToolBarType)targetToolBar;
- (void)updateFilterImage:(DistFilter *)filter;
@end

@protocol DistControllToolBarDelegate <NSObject>
@required
- (void)changeFilter:(DistControllToolBar *)toolBar;
- (void)takePicture:(DistControllToolBar *)toolBar;
- (void)switchCamera:(DistControllToolBar *)toolBar;
- (void)changeSetting:(DistControllToolBar *)toolBar;
- (void)cancelSavePhoto:(DistControllToolBar *)toolBar;
- (void)savePhoto:(DistControllToolBar *)toolBar;
@end