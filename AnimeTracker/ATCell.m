//
//  ATCell.m
//  AnimeTracker
//
//  Created by Evan Purkhiser on 10/18/13.
//  Copyright (c) 2013 Evan Purkhiser. All rights reserved.
//

#import "ATCell.h"

@implementation ATCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.bounds = CGRectMake(10, 2, 28, 40);
    self.imageView.frame  = self.imageView.bounds;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;

    self.separatorInset = UIEdgeInsetsMake(0, 48, 0, 0);
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = 48;
    self.textLabel.frame = textLabelFrame;
}

@end
