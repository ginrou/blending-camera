//
//  BCPartsView.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/11/07.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCPartsView.h"

@implementation BCPartsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        tapGestureRecognizer.numberOfTouchesRequired = 1;
        tapGestureRecognizer.numberOfTapsRequired    = 1;
        [self addGestureRecognizer:tapGestureRecognizer];
        
        self.userInteractionEnabled = YES;
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [_image drawInRect:self.bounds];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"single tap");
}


@end
