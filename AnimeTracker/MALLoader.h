//
//  MALLoader.h
//  AnimeTracker
//
//  Created by Evan Purkhiser on 10/18/13.
//  Copyright (c) 2013 Evan Purkhiser. All rights reserved.
//

#import "Anime.h"

#import <Foundation/Foundation.h>

@interface MALLoader : NSObject

+ (NSDictionary *)getAnimeListFor:(NSString *)username;

@end

@interface Anime (MALLoader)

- (void)setDataFromMAL:(NSDictionary *)anime;

@end