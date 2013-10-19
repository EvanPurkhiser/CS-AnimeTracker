//
//  MALLoader.m
//  AnimeTracker
//
//  Created by Evan Purkhiser on 10/18/13.
//  Copyright (c) 2013 Evan Purkhiser. All rights reserved.
//

#import "InfoLoader.h"
#import "XMLDictionary/XMLDictionary.h"

#define MAL_ANIME_LIST_URL @"http://myanimelist.net/malappinfo.php?status=all&type=anime&u=%@"
#define TVDB_Show_SEARCH   @"http://thetvdb.com/api/GetSeries.php?seriesname=%@"
#define TVDB_BANNER_URL    @"http://thetvdb.com/banners/%@"

@implementation InfoLoader

+ (NSDictionary *)getAnimeListFor:(NSString *)username
{
    username = [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *animeListURL = [NSURL URLWithString:[NSString stringWithFormat:MAL_ANIME_LIST_URL, username]];

    // Get the data from the URL
    NSData *data = [NSData dataWithContentsOfURL:animeListURL];
    return [NSDictionary dictionaryWithXMLData:data];
}

+ (NSDictionary *)getAnimeInfo:(NSString *)title
{
    title = [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *searchURL = [NSURL URLWithString:[NSString stringWithFormat:TVDB_Show_SEARCH, title]];

    // Get the data from the URL
    NSData *data = [NSData dataWithContentsOfURL:searchURL];
    NSDictionary *anime = [NSDictionary dictionaryWithXMLData:data][@"Series"];

    // Just take the first result if multiple came back. This is certinally prone to error
    // But what can we really do? We really should standardize on one service instead of
    // using multiple services that overlap
    if ([anime isKindOfClass:[NSArray class]])
    {
        return ((NSArray *) anime)[0];
    }

    return anime;
}

@end

@implementation Anime (MALLoader)

- (BOOL)discardIfidMALExists
{
    NSManagedObjectContext *context = [self managedObjectContext];

    // Check if this specific anime already exists as a entity
    NSFetchRequest *request = [NSFetchRequest new];
    request.entity = [self entity];
    request.predicate = [NSPredicate predicateWithFormat:@"idMAL == %@", self.idMAL];

    // Discard this object if this anime now exists twice
    if ([context countForFetchRequest:request error:nil] > 1)
    {
        [context deleteObject:self];
        return YES;
    }

    return NO;
}

- (void)setDataFromMAL:(NSDictionary *)anime
{
    if (anime == nil) return;

    // Setup the values
    self.idMAL           = [[NSNumberFormatter alloc] numberFromString:anime[@"series_animedb_id"]];
    self.episodesTotal   = [[NSNumberFormatter alloc] numberFromString:anime[@"series_episodes"]];
    self.episodesWatched = [[NSNumberFormatter alloc] numberFromString:anime[@"my_watched_episodes"]];
    self.rating          = [[NSNumberFormatter alloc] numberFromString:anime[@"my_score"]];
    self.firstAirDate    = [[NSDateFormatter new] dateFromString:anime[@"series_start"]];
    self.name            = anime[@"series_title"];
    self.airingStatus    = anime[@"my_status"];

    if ([self discardIfidMALExists]) return;
    
    // Store image as a BLOB in the database. Yes I realize the implications
    // of storing binary data into a database, and yes this is very rarely a
    // good idea. But this is pretty _damn cool_ so why not.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
    ^{
        NSData *image = [NSData dataWithContentsOfURL:[NSURL URLWithString:anime[@"series_image"]]];
                       
        dispatch_async(dispatch_get_main_queue(),
        ^{
            self.imagePoster = image;
            [[self managedObjectContext] save:nil];
        });
    });
}

- (void)setDataFromTVDB:(NSDictionary *)anime
{
    if (anime == nil) return;

    // Setup the values
    self.idTVDB  = [[NSNumberFormatter alloc] numberFromString:anime[@"seriesid"]];
    self.summary = anime[@"Overview"];
    self.network = anime[@"Network"];

    if ( ! self.firstAirDate)
    {
        self.firstAirDate = [[NSDateFormatter new] dateFromString:anime[@"FirstAired"]];
    }

    // Again, store the banner as a BLOB
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
    ^{
        NSURL *bannerURL = [NSURL URLWithString:[NSString stringWithFormat:TVDB_BANNER_URL, anime[@"banner"]]];
        NSData *image = [NSData dataWithContentsOfURL:bannerURL];

        dispatch_async(dispatch_get_main_queue(),
        ^{
            self.imageBanner = image;
            [[self managedObjectContext] save:nil];
        });
    });
}

@end
