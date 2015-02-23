//
//  Tweet.h
//  Twitter
//
//  Created by Calvin Tuong on 2/18/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, assign) long long tweetId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) User *author;
@property (nonatomic, assign) NSInteger favoriteCount;
@property (nonatomic, assign) NSInteger retweetCount;
@property (nonatomic, strong) Tweet *retweetedStatus;
@property (nonatomic, assign, getter=isFavorited) BOOL favorited;
@property (nonatomic, assign, getter=isRetweeted) BOOL retweeted;

- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)tweetsWithArray:(NSArray *)array;
// if the tweet is a retweeted tweet, get the retweeted tweet
// otherwise just return the tweet
- (Tweet *)actualTweet;

// favorite this tweet, setting the favorite count as well
- (void)setFavoritedState:(BOOL)state;
// retweet this tweet, setting the retweet count as well
- (void)setRetweetedState:(BOOL)state;

@end
