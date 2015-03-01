//
//  MentionsViewController.m
//  Twitter
//
//  Created by Calvin Tuong on 2/28/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "MentionsViewController.h"
#import "TweetListViewControllerPrivate.h"

@implementation MentionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Mentions";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NewTweetViewControllerDelegate methods

- (void)newTweetViewController:(NewTweetViewController *)newTweetViewController didPostTweet:(NSString *)tweetText {
    NSDictionary *params = nil;
    if (newTweetViewController.inReplyToTweet) {
        params = [NSDictionary dictionaryWithObjects:@[@(newTweetViewController.inReplyToTweet.tweetId)] forKeys:@[@"in_reply_to_status_id"]];
    }
    
    [[TwitterClient sharedInstance] postTweet:tweetText params:params completion:^(Tweet *tweet, NSError *error) {
        if (error) {
            NSLog(@"Error posting tweet: %@", error);
        }
    }];
}

#pragma mark - Private methods

- (void)getTweets {
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD show];
    [[TwitterClient sharedInstance] mentionsTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        if (!error) {
            self.tweets = tweets;
            
            [self addObserverForTweets:self.tweets];
            
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        } else {
            NSLog(@"Error retrieving tweets: %@", error);
        }
    }];
}

- (void)refreshTweets {
    NSDictionary *params = nil;
    if (self.tweets.count > 0) {
        long long sinceId = ((Tweet *)self.tweets[0]).tweetId;
        params = [NSDictionary dictionaryWithObjects:@[@(sinceId)] forKeys:@[@"since_id"]];
    }
    
    [[TwitterClient sharedInstance] mentionsTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
        // put the new tweets at the beginning of the existing tweets list
        self.tweets = [tweets arrayByAddingObjectsFromArray:self.tweets];
        
        [self addObserverForTweets:self.tweets];
        
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void)getMoreTweets {
    NSDictionary *params = nil;
    if (self.tweets.count > 0) {
        long long maxId = ((Tweet *)self.tweets[self.tweets.count - 1]).tweetId;
        // use maxId - 1 so we don't get a repeated tweet
        params = [NSDictionary dictionaryWithObjects:@[@(maxId - 1)] forKeys:@[@"max_id"]];
    }
    
    [[TwitterClient sharedInstance] mentionsTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
        [self addObserverForTweets:tweets];
        
        self.tweets = [self.tweets arrayByAddingObjectsFromArray:tweets];
        [self.tableView reloadData];
        [[self.tableView infiniteScrollingView] stopAnimating];
    }];
}

@end
