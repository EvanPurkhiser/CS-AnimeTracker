//
//  ATMasterViewController.h
//  AnimeTracker
//
//  Created by Evan Purkhiser on 10/17/13.
//  Copyright (c) 2013 Evan Purkhiser. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface ATMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
