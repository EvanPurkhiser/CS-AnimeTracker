//
//  ATDetailViewController.h
//  AnimeTracker
//
//  Created by Evan Purkhiser on 10/17/13.
//  Copyright (c) 2013 Evan Purkhiser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATDetailViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel        *name;
@property (weak, nonatomic) IBOutlet UIImageView    *banner;
@property (weak, nonatomic) IBOutlet UITextView     *summary;
@property (weak, nonatomic) IBOutlet UITextField    *watchedEpisodes;
@property (weak, nonatomic) IBOutlet UITextField    *totalEpisodes;
@property (weak, nonatomic) IBOutlet UIProgressView *episodeProgress;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView       *scrollViewContainer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *summaryHeightConstraint;

@end
