//
//  TweetDetailViewController.h
//  Twitter
//
//  Created by Calvin Tuong on 2/22/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "TweetActionDelegate.h"

@interface TweetDetailViewController : UIViewController

@property (nonatomic, strong) Tweet *tweet;

@property (weak, nonatomic) id<TweetActionDelegate> tweetActionDelegate;

@end
