//
//  Show.m
//  AnimeTracker
//
//  Created by Evan Purkhiser on 10/17/13.
//  Copyright (c) 2013 Evan Purkhiser. All rights reserved.
//

#import "Show.h"


@implementation Show

@dynamic episodesTotal;
@dynamic episodesWatched;
@dynamic name;
@dynamic notes;
@dynamic rating;
@dynamic watchingFinishedOn;
@dynamic watchingStartedOn;
@dynamic airingStatus;
@dynamic summary;

- (void)setDataFromMAL:(NSDictionary *)anime
{
    self.episodesTotal = anime[@"episodes"];
    self.episodesWatched = anime[@"watched_episodes"];
    self.name = anime[@"title"];
    self.rating = anime[@"score"];
    self.airingStatus = anime[@"status"];
}

@end
