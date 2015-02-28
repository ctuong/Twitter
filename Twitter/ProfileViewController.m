//
//  ProfileViewController.m
//  Twitter
//
//  Created by Calvin Tuong on 2/26/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "ProfileViewController.h"
#import "TweetCell.h"
#import "TwitterClient.h"
#import <UIImageView+AFNetworking.h>

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *tweets;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Profile";
    
    [self initElementsFromUser:self.user];
    
    self.tweets = [NSArray array];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self getTweets];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self removeObserverForTweets:self.tweets];
}

- (void)initElementsFromUser:(User*) user {
    [self.bannerImageView setImageWithURL:[NSURL URLWithString:user.profileBackgroundImageURL]];
    [self.profileImageView setImageWithURL:[NSURL URLWithString:user.profileImageURL]];
    self.profileImageView.layer.cornerRadius = 3;
    self.profileImageView.clipsToBounds = YES;
    self.nameLabel.text = user.name;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.username];
    self.tweetCountLabel.text = [NSString stringWithFormat:@"%ld", user.tweetCount];
    self.followingCountLabel.text = [NSString stringWithFormat:@"%ld", user.followingCount];
    self.followerCountLabel.text = [NSString stringWithFormat:@"%ld", user.followerCount];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    
    cell.tweet = self.tweets[indexPath.row];
//    cell.tweetActionDelegate = self;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private methods

- (void)getTweets {
    [[TwitterClient sharedInstance] userTimelineForUser:self.user params:nil completion:^(NSArray *tweets, NSError *error) {
        if (!error) {
            self.tweets = tweets;
            [self addObserverForTweets:self.tweets];
            [self.tableView reloadData];
        } else {
            NSLog(@"Error retrieving tweets: %@", error);
        }
    }];
}

- (void)addObserverForTweets:(NSArray *)tweets {
    for (Tweet *tweet in tweets) {
        [tweet addObserver:self forKeyPath:@"favorited" options:NSKeyValueObservingOptionNew context:NULL];
        [tweet addObserver:self forKeyPath:@"retweeted" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)removeObserverForTweets:(NSArray *)tweets {
    for (Tweet *tweet in tweets) {
        [tweet removeObserver:self forKeyPath:@"favorited"];
        [tweet removeObserver:self forKeyPath:@"retweeted"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    Tweet *tweet = (Tweet *)object;
    NSInteger index = [self.tweets indexOfObject:tweet];
    
    // reload that cell
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

@end
