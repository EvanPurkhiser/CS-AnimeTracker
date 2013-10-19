//
//  MALLoader.m
//  AnimeTracker
//
//  Created by Evan Purkhiser on 10/18/13.
//  Copyright (c) 2013 Evan Purkhiser. All rights reserved.
//

#import "MALLoader.h"
#import "XMLDictionary/XMLDictionary.h"

#define MAL_ANIME_LIST_URL @"http://myanimelist.net/malappinfo.php?status=all&type=anime&u=%@"

@implementation MALLoader

+ (NSDictionary *)getAnimeListFor:(NSString *)username
{
    NSURL *animeListURL = [NSURL URLWithString:[NSString stringWithFormat:MAL_ANIME_LIST_URL, username]];

    // Get the data from the URL.. this could take awhiel
    NSData *data = [NSData dataWithContentsOfURL:animeListURL];
    return [NSDictionary dictionaryWithXMLData:data];
}

@end

@implementation Anime (MALLoader)

- (void)setDataFromMAL:(NSDictionary *)anime
{
    self.idMAL           = [[NSNumberFormatter alloc] numberFromString:anime[@"series_animedb_id"]];
    self.episodesTotal   = [[NSNumberFormatter alloc] numberFromString:anime[@"series_episodes"]];
    self.episodesWatched = [[NSNumberFormatter alloc] numberFromString:anime[@"my_watched_episodes"]];
    self.rating          = [[NSNumberFormatter alloc] numberFromString:anime[@"my_score"]];
    self.name            = anime[@"series_title"];
    self.airingStatus    = anime[@"my_status"];

    // Store image as a BLOB in the database. Yes I realize the implications
    // of storing binary data into a database, and yes this is very rarely a
    // good idea. But this is pretty _damn cool_ so why not.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
    ^{
        NSData *image = [NSData dataWithContentsOfURL:[NSURL URLWithString:anime[@"series_image"]]];

        dispatch_async(dispatch_get_main_queue(),
        ^{
            self.image = image;
            [[self managedObjectContext] save:nil];
        });
    });
}

@end
