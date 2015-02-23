//
//  TweetCell.h
//  Twitter
//
//  Created by Calvin Tuong on 2/19/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "TweetActionDelegate.h"

@interface TweetCell : UITableViewCell

@property (nonatomic, strong) Tweet *tweet;

@property (weak, nonatomic) id<TweetActionDelegate> tweetActionDelegate;

@end
