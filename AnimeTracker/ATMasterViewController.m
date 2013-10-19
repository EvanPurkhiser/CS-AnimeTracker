//
//  ATMasterViewController.m
//  AnimeTracker
//
//  Created by Evan Purkhiser on 10/17/13.
//  Copyright (c) 2013 Evan Purkhiser. All rights reserved.
//

#import "ATMasterViewController.h"
#import "ATDetailViewController.h"
#import "Anime.h"
#import "MALLoader.h"

@interface ATMasterViewController ()

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)importFromMAL:(id)sender;

@end

@implementation ATMasterViewController

NSArray *rightButtonsNormal;
NSArray *rightButtonsImporting;

NSArray *leftButtonsNormal;
NSArray *leftButtonsEditing;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup all of the UIBarButtonItems that may appear to the right
    UIBarButtonItem *addButton    = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    UIBarButtonItem *importButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(importFromMAL:)];
    
    UIActivityIndicatorView *throbber = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32, 20)];
    throbber.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    UIBarButtonItem *throbberButton = [[UIBarButtonItem alloc] initWithCustomView:throbber];
    [throbber startAnimating];
    
    rightButtonsNormal    = @[addButton, importButton];
    rightButtonsImporting = @[addButton, throbberButton];

    UIBarButtonItem *clearButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(removeAllObjects:)];
    clearButton.tintColor = [UIColor redColor];
    
    leftButtonsEditing = @[self.editButtonItem, clearButton];
    leftButtonsNormal  = @[self.editButtonItem];
    
    self.navigationItem.leftBarButtonItems  = leftButtonsNormal;
    self.navigationItem.rightBarButtonItems = rightButtonsNormal;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:@"New Show" forKey:@"name"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    NSLog(@"is animaated: %d", animated);
    
    if (editing)
    {
        self.navigationItem.leftBarButtonItems = leftButtonsEditing;
    }
    else
    {
        self.navigationItem.leftBarButtonItems = leftButtonsNormal;
    }
}

- (void)removeAllObjects:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest *allAnime = [NSFetchRequest new];
    allAnime.entity = [NSEntityDescription entityForName:@"Anime" inManagedObjectContext:context];
    allAnime.includesPropertyValues = NO;
    
    for (Anime *anime in [context executeFetchRequest:allAnime error:nil])
    {
        [context deleteObject:anime];
    }
    
    [context save:nil];
}

- (void)importFromMAL:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Import Anime List" message:@"Enter a MyAnimeList Username" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Import", nil];

    // Add input box
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *usernameInput = [alert textFieldAtIndex:0];

    [alert show];

    // Default to my MAL username (Because really, I'm the only nerd who keeps track of what Anime they've watched..)
    usernameInput.text = @"EvanPurkhiser";

    // Make the input box
    usernameInput.textAlignment   = NSTextAlignmentCenter;
}

- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonId
{
    // This is only used for importing from MAL
    if (buttonId == alert.cancelButtonIndex) return;
    
    // Change the navigation buttons to the importing state
    self.navigationItem.rightBarButtonItems = rightButtonsImporting;

    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];

    // Load the animelist in a thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
    ^{
        // Load anime list from MAL
        NSString *username  = [alert textFieldAtIndex:0].text;
        NSDictionary *animeList = [MALLoader getAnimeListFor:username];
        
        // Load each Anime into the data store
        for (NSDictionary *anime in animeList[@"anime"])
        {
            [[[Anime alloc] initWithEntity:entity insertIntoManagedObjectContext:context] setDataFromMAL:anime];
        }

        // Updates must happen on the main thread
        dispatch_async(dispatch_get_main_queue(),
        ^{
            if (animeList[@"error"])
            {
                [[[UIAlertView alloc] initWithTitle:@"Problem Importing Anime List" message:animeList[@"error"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            }

            // Return the right navigation buttons to the normal set
            self.navigationItem.rightBarButtonItems = rightButtonsNormal;
            
            [context save:nil];
        });

    });
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];

    // Crop the image into
    
    
    // Cleanup the iamgeView styling
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 2;
    cell.imageView.layer.minificationFilter = kCAFilterTrilinear;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Anime" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a craS log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text  = [[object valueForKey:@"name"] description];
    cell.imageView.image = [UIImage imageWithData:[object valueForKey:@"image"]];
}

@end
