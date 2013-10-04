//
//  INDetailViewController.h
//  Info
//
//  Created by Michael Collard on 10/4/13.
//  Copyright (c) 2013 collard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
