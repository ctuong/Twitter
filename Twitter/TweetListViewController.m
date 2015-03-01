//
//  TweetListViewController.m
//  Twitter
//
//  Created by Calvin Tuong on 2/28/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "TweetListViewController.h"
#import "TweetListViewControllerPrivate.h"

@implementation TweetListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tweets = [NSArray array];
    self.placeholderTweet = nil;
    
    // place the table under the nav bar
//    id topGuide = self.topLayoutGuide;
//    UITableView *tableView = self.tableView;
//    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(tableView, topGuide);
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0-[tableView]" options:0 metrics:nil views:viewsDictionary]];
    
    // set up the table
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    [self getTweets];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [self getMoreTweets];
    }];
    
    // set up pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTweets) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.placeholderTweet) {
        return self.tweets.count + 1;
    }
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    
    NSInteger index = indexPath.row;
    
    if (self.placeholderTweet) {
        if (index == 0) {
            cell.tweet = self.placeholderTweet;
        } else {
            cell.tweet = self.tweets[index - 1];
        }
    } else {
        cell.tweet = self.tweets[index];
    }
    
    cell.tweetActionDelegate = self;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Tweet *tweet = self.tweets[indexPath.row];
    TweetDetailViewController *tdvc = [[TweetDetailViewController alloc] init];
    tdvc.tweet = tweet;
    tdvc.tweetActionDelegate = self;
    
    [self.navigationController pushViewController:tdvc animated:YES];
}

#pragma mark - NewTweetViewControllerDelegate methods

- (void)newTweetViewController:(NewTweetViewController *)newTweetViewController didPostTweet:(NSString *)tweetText {
    NSDictionary *params = nil;
    if (newTweetViewController.inReplyToTweet) {
        params = [NSDictionary dictionaryWithObjects:@[@(newTweetViewController.inReplyToTweet.tweetId)] forKeys:@[@"in_reply_to_status_id"]];
    }
    
    [[TwitterClient sharedInstance] postTweet:tweetText params:params completion:^(Tweet *tweet, NSError *error) {
        if (error) {
            self.placeholderTweet = nil;
            [self.tableView reloadData];
            NSLog(@"Error posting tweet: %@", error);
        } else {
            // update the placeholder tweet with this one
            self.placeholderTweet = nil;
            NSArray *newTweet = @[tweet];
            self.tweets = [newTweet arrayByAddingObjectsFromArray:self.tweets];
            [self.tableView reloadData];
        }
    }];
    
    self.placeholderTweet = [Tweet placeholderTweetWithText:tweetText user:[User currentUser]];
    [self.tableView reloadData];
}

#pragma mark - TweetActionDelegate methods

- (void)favoriteForTweet:(Tweet *)tweet sender:(id)sender {
    BOOL currentState = tweet.isFavorited;
    
    if (currentState) {
        [[TwitterClient sharedInstance] unfavoriteTweet:tweet completion:^(Tweet *returnedTweet, NSError *error) {
            if (error) {
                NSLog(@"Error unfavoriting tweet: %@", error);
                // change the favorited status of the tweet back to YES
                [tweet setFavoritedState:YES];
            }
        }];
    } else {
        [[TwitterClient sharedInstance] favoriteTweet:tweet completion:^(Tweet *returnedTweet, NSError *error) {
            if (error) {
                NSLog(@"Error favoriting tweet: %@", error);
                // change the favorited status of the tweet back to NO
                [tweet setFavoritedState:NO];
            }
        }];
    }
    
    [tweet setFavoritedState:!currentState];
}

- (void)retweetTweet:(Tweet *)tweet sender:(id)sender {
    [[TwitterClient sharedInstance] retweetTweet:tweet params:nil completion:^(Tweet *returnedTweet, NSError *error) {
        if (error) {
            // change the retweeted status of the tweet back to NO
            [tweet setRetweetedState:NO];
        }
    }];
    
    [tweet setRetweetedState:YES];
}

- (void)replyToTweet:(Tweet *)tweet sender:(id)sender {
    NewTweetViewController *ntvc = [[NewTweetViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:ntvc];
    ntvc.delegate = self;
    ntvc.inReplyToTweet = tweet;
    
    if ([sender respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [sender presentViewController:nvc animated:YES completion:nil];
    } else {
        [self presentViewController:nvc animated:YES completion:nil];
    }
}

- (void)userImageViewTappedForUser:(User *)user {
    ProfileViewController *pvc = [[ProfileViewController alloc] init];
    pvc.user = user;
    
    [self.navigationController pushViewController:pvc animated:YES];
}

#pragma mark - Private methods

- (void)getTweets {
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD show];
    [[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
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
    
    [[TwitterClient sharedInstance] homeTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
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
    
    [[TwitterClient sharedInstance] homeTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
        [self addObserverForTweets:tweets];
        
        self.tweets = [self.tweets arrayByAddingObjectsFromArray:tweets];
        [self.tableView reloadData];
        [[self.tableView infiniteScrollingView] stopAnimating];
    }];
}

- (void)addObserverForTweets:(NSArray *)tweets {
    for (Tweet *tweet in tweets) {
        [tweet addObserver:self forKeyPath:@"favorited" options:NSKeyValueObservingOptionNew context:NULL];
        [tweet addObserver:self forKeyPath:@"retweeted" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    Tweet *tweet = (Tweet *)object;
    NSInteger index = [self.tweets indexOfObject:tweet];
    
    // reload that cell
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

@end
