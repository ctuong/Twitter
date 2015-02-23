//
//  TweetsViewController.m
//  Twitter
//
//  Created by Calvin Tuong on 2/18/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "TweetsViewController.h"
#import "User.h"
#import "TwitterClient.h"
#import "Tweet.h"
#import "TweetCell.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "NewTweetViewController.h"
#import "TweetDetailViewController.h"
#import "TweetActionDelegate.h"

@interface TweetsViewController () <UITableViewDataSource, UITableViewDelegate, NewTweetViewControllerDelegate, TweetActionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *tweets;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TweetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Home";
    
    self.tweets = [NSArray array];
    
    // place the table under the nav bar
    id topGuide = self.topLayoutGuide;
    UITableView *tableView = self.tableView;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(tableView, topGuide);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0-[tableView]" options:0 metrics:nil views:viewsDictionary]];
    
    // set up the table
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    [self getTweets];
    
    // set up pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTweets) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    // set up the nav bar buttons
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];
    logoutButton.tintColor = [UIColor colorWithWhite:1 alpha:1];
    self.navigationItem.leftBarButtonItem = logoutButton;
    
    UIBarButtonItem *newTweetButton = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(onNewTweetButton)];
    newTweetButton.tintColor = [UIColor colorWithWhite:1 alpha:1];
    self.navigationItem.rightBarButtonItem = newTweetButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    
    cell.tweet = self.tweets[indexPath.row];
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

- (void)newTweetViewController:(NewTweetViewController *)newTweetViewController didPostTweet:(Tweet *)tweet {
    // TODO implement for optional
}

#pragma mark - TweetActionDelegate methods

- (void)favoriteForTweet:(Tweet *)tweet sender:(id)sender {
    BOOL currentState = tweet.isFavorited;
    
    if (currentState) {
        [[TwitterClient sharedInstance] unfavoriteTweet:tweet completion:^(Tweet *returnedTweet, NSError *error) {
            if (error) {
                // change the favorited status of the tweet back to YES
                [tweet setFavoritedState:YES];
            }
        }];
    } else {
        [[TwitterClient sharedInstance] favoriteTweet:tweet completion:^(Tweet *returnedTweet, NSError *error) {
            if (error) {
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

#pragma mark - Private methods

- (void)onLogout {
    [User logout];
}

- (void)onNewTweetButton {
    NewTweetViewController *ntvc = [[NewTweetViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:ntvc];
    
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)getTweets {
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD show];
    [[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        if (!error) {
            self.tweets = tweets;
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
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
