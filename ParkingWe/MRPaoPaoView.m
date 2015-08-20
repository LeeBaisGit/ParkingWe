//
//  MRPaoPaoView.m
//  ParkingWe
//
//  Created by 李白 on 15-8-12.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRPaoPaoView.h"

@implementation MRPaoPaoView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}


- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.bounds = CGRectMake(0, 0, 200, 100);
    self.backgroundColor = [UIColor redColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    Mylog(@"%@", self.subviews);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
