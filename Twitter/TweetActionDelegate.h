//
//  TweetActionDelegate.h
//  Twitter
//
//  Created by Calvin Tuong on 2/22/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweet.h"

@protocol TweetActionDelegate <NSObject>

- (void)favoriteForTweet:(Tweet *)tweet sender:(id)sender;
- (void)retweetTweet:(Tweet *)tweet sender:(id)sender;
- (void)replyToTweet:(Tweet *)tweet sender:(id)sender;

@end
