//
//  TweetListViewControllerPrivate.h
//  Twitter
//
//  Created by Calvin Tuong on 2/28/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#ifndef Twitter_TweetListViewControllerPrivate_h
#define Twitter_TweetListViewControllerPrivate_h

#import "User.h"
#import "TwitterClient.h"
#import "Tweet.h"
#import "TweetCell.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "NewTweetViewController.h"
#import "TweetDetailViewController.h"
#import "TweetActionDelegate.h"
#import "ProfileViewController.h"
#import <UIScrollView+SVInfiniteScrolling.h>

@interface TweetListViewController () <UITableViewDataSource, UITableViewDelegate, NewTweetViewControllerDelegate, TweetActionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *tweets;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

// set when a tweet is posted so we can display it immediately
@property (nonatomic, strong) Tweet *placeholderTweet;

- (void)addObserverForTweets:(NSArray *)tweets;

@end

#endif
