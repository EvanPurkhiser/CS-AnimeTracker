//
//  Anime.h
//  AnimeTracker
//
//  Created by Evan Purkhiser on 10/17/13.
//  Copyright (c) 2013 Evan Purkhiser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Anime : NSManagedObject

@property (nonatomic, retain) NSNumber * episodesTotal;
@property (nonatomic, retain) NSNumber * episodesWatched;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSDate * watchingFinishedOn;
@property (nonatomic, retain) NSDate * watchingStartedOn;
@property (nonatomic, retain) NSString * airingStatus;
@property (nonatomic, retain) NSString * summary;

- (void)setDataFromMAL:(NSDictionary *)anime;

@end
