//
//  ATDetailViewController.h
//  AnimeTracker
//
//  Created by Evan Purkhiser on 10/17/13.
//  Copyright (c) 2013 Evan Purkhiser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
