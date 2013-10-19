//
//  ATDetailViewController.m
//  AnimeTracker
//
//  Created by Evan Purkhiser on 10/17/13.
//  Copyright (c) 2013 Evan Purkhiser. All rights reserved.
//

#import "ATDetailViewController.h"
#import "InfoLoader.h"

@interface ATDetailViewController ()
- (void)configureView;
@end

@implementation ATDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;

        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    if ( ! self.detailItem) return;

    self.banner.image = [UIImage imageWithData:[self.detailItem valueForKey:@"imageBanner"]];

    // Constrain the banner to scale properly
    float scale = self.banner.image.size.height / self.banner.image.size.width;

    if (scale == scale && scale)
    {
        [self.banner addConstraint:[NSLayoutConstraint
            constraintWithItem:self.banner
            attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:self.banner
            attribute:NSLayoutAttributeWidth
            multiplier:self.banner.image.size.height / self.banner.image.size.width
            constant:0]];
    }

    // Setup the anime title, numberOfLines = 0 will allow it to wrap
    self.name.text = [[self.detailItem valueForKey:@"name"] description];
    self.name.numberOfLines = 0;

    self.summary.text = [[self.detailItem valueForKey:@"summary"] description];

    self.watchedEpisodes.text = [[self.detailItem valueForKey:@"episodesWatched"] description];
    self.totalEpisodes.text   = [[self.detailItem valueForKey:@"episodesTotal"] description];
    self.episodeProgress.progress = [self.watchedEpisodes.text floatValue] / [self.totalEpisodes.text floatValue];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    [self.summaryHeightConstraint setConstant:self.summary.contentSize.height];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];

    // Constrain the containerView (that's inside the scroll view) to the main view so
    // that it stays the proper width inside of the scroll view and allows us to constrain
    // other UI elements in IB without having to deal with code
    // http://stackoverflow.com/a/16471244/690169
    UIView *view = self.view;
    UIView *containerView = self.scrollViewContainer;

    NSDictionary *views = NSDictionaryOfVariableBindings(containerView, view);
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[containerView(==view)]|" options:0 metrics:nil views:views]];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.watchedEpisodes.enabled = NO;
    self.totalEpisodes.enabled = NO;


    // Load data from the TVDB about this series if possible
    if ([self.detailItem valueForKey:@"idTVDB"] == nil)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
        ^{
            [self.detailItem setDataFromTVDB:[InfoLoader getAnimeInfo:[self.detailItem valueForKey:@"name"]]];
            dispatch_async(dispatch_get_main_queue(), ^{[[self.detailItem managedObjectContext] save:nil]; });
        });
    }

    // Fire an event when it's updated
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateDetailItem:) name:NSManagedObjectContextDidSaveNotification object:[self.detailItem managedObjectContext]];
}

- (void)didUpdateDetailItem:(NSNotification *)notification
{
    [self configureView];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    self.watchedEpisodes.enabled = editing;
    self.totalEpisodes.enabled = editing;
    self.summary.editable = editing;

    // Save back into the managed object
    if ( ! editing)
    {
        NSNumber *watched = [[NSNumberFormatter alloc] numberFromString:self.watchedEpisodes.text];
        NSNumber *total   = [[NSNumberFormatter alloc] numberFromString:self.totalEpisodes.text];

        [self.detailItem setValue:watched forKey:@"episodesWatched"];
        [self.detailItem setValue:total forKey:@"episodesTotal"];
        [self.detailItem setValue:self.summary.text forKey:@"summary"];

        [[self.detailItem managedObjectContext] save:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
