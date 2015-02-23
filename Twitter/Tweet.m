//
//  Tweet.m
//  Twitter
//
//  Created by Calvin Tuong on 2/18/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        // TODO how to handle placeholder ids?
        self.tweetId = [dictionary[@"id"] longLongValue];
        self.text = dictionary[@"text"];
        self.author = [[User alloc] initWithDictionary:dictionary[@"user"]];
        NSString *createdAtString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        self.createdAt = [formatter dateFromString:createdAtString];
        
        self.favoriteCount = [dictionary[@"favorite_count"] integerValue];
        self.retweetCount = [dictionary[@"retweet_count"] integerValue];
        
        self.retweetedStatus = nil;
        if (dictionary[@"retweeted_status"]) {
            self.retweetedStatus = [[Tweet alloc] initWithDictionary:dictionary[@"retweeted_status"]];
        }
        
        self.favorited = [dictionary[@"favorited"] boolValue];
        self.retweeted = [dictionary[@"retweeted"] boolValue];
    }
    
    return self;
}

+ (NSArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
    }
    
    return tweets;
}

- (Tweet *)actualTweet {
    if (self.retweetedStatus) {
        return self.retweetedStatus;
    }
    return self;
}

- (void)setFavoritedState:(BOOL)state {
    self.favorited = state;
    if (state) {
        self.favoriteCount += 1;
    } else {
        self.favoriteCount -= 1;
    }
}

- (void)setRetweetedState:(BOOL)state {
    self.retweeted = state;
    if (state) {
        self.retweetCount += 1;
    } else {
        self.retweetCount -= 1;
    }
}

@end
