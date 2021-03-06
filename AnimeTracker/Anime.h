//
//  Anime.h
//  AnimeTracker
//
//  Created by Evan Purkhiser on 10/19/13.
//  Copyright (c) 2013 Evan Purkhiser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Anime : NSManagedObject

@property (nonatomic, retain) NSString * airingStatus;
@property (nonatomic, retain) NSNumber * episodesTotal;
@property (nonatomic, retain) NSNumber * episodesWatched;
@property (nonatomic, retain) NSNumber * idMAL;
@property (nonatomic, retain) NSData * imagePoster;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSDate * watchingFinishedOn;
@property (nonatomic, retain) NSDate * watchingStartedOn;
@property (nonatomic, retain) NSNumber * idTVDB;
@property (nonatomic, retain) NSDate * firstAirDate;
@property (nonatomic, retain) NSString * network;
@property (nonatomic, retain) NSData * imageBanner;

@end
