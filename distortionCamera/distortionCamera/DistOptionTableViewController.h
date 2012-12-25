//
//  DistOptionTableViewController.h
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/25.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DistOptionTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *detectionAccuracyControl;
@property (weak, nonatomic) IBOutlet UISwitch *colorAdjustmentSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *flashSwitch;


- (IBAction)detectionAccuracyChanged:(UISegmentedControl *)sender;
- (IBAction)autoIntensityCollectionChanged:(UISwitch *)sender;
- (IBAction)FlashChanged:(UISwitch *)sender;

@end
