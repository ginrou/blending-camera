//
//  DistOptionTableViewController.m
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/25.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "DistOptionTableViewController.h"
#import "DistOptions.h"

@interface DistOptionTableViewController ()
@property (nonatomic, strong) NSArray *cellHeightList;
@end

@implementation DistOptionTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self applyOptions];
    self.cellHeightList = @[@95.0, @45.0, @45.0];

    CGFloat heightSum = 20.0; // initial offset
    for (NSNumber *height in _cellHeightList) heightSum += [height floatValue];

    self.view.height = heightSum;


}

- (void)applyOptions
{
    if ([[DistOptions loadDetectorAccuray] isEqualToString:CIDetectorAccuracyLow]) {
        _detectionAccuracyControl.selectedSegmentIndex = 0;
    } else {
        _detectionAccuracyControl.selectedSegmentIndex = 1;
    }

    [_colorAdjustmentSwitch setOn:[DistOptions loadAutoIntensityCollection]];
    [_flashSwitch setOn:[DistOptions loadFlash]];
}

- (void)viewDidUnload {
    [self setDetectionAccuracyControl:nil];
    [self setColorAdjustmentSwitch:nil];
    [self setFlashSwitch:nil];
    [super viewDidUnload];
}


#pragma mark - actions
- (IBAction)detectionAccuracyChanged:(UISegmentedControl *)sender {

    if (sender.selectedSegmentIndex == 0) { // Low
        [DistOptions saveDetectorAccuracy:CIDetectorAccuracyLow];
    } else { // High
        [DistOptions saveDetectorAccuracy:CIDetectorAccuracyHigh];
    }
}

- (IBAction)autoIntensityCollectionChanged:(UISwitch *)sender {
    BOOL enable = sender.isOn;
    [DistOptions saveAutoIntensityCollection:enable];
}

- (IBAction)FlashChanged:(UISwitch *)sender {
    BOOL enable = sender.isOn;
    [DistOptions saveFlash:enable];
}
@end
