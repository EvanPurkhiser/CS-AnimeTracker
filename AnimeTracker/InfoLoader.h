//
//  MALLoader.h
//  AnimeTracker
//
//  Created by Evan Purkhiser on 10/18/13.
//  Copyright (c) 2013 Evan Purkhiser. All rights reserved.
//

#import "Anime.h"

#import <Foundation/Foundation.h>

@interface InfoLoader : NSObject

+ (NSDictionary *)getAnimeListFor:(NSString *)username;
+ (NSDictionary *)getAnimeInfo:(NSString *)title;

@end

@interface Anime (MALLoader)

- (BOOL)discardIfidMALExists;
- (void)setDataFromMAL:(NSDictionary *)anime;
- (void)setDataFromTVDB:(NSDictionary *)anime;

@end