//
//  TweetDetailViewController.m
//  Twitter
//
//  Created by Calvin Tuong on 2/22/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "TweetDetailViewController.h"
#import <UIImageView+AFNetworking.h>
#import "TwitterClient.h"
#import "ProfileViewController.h"

@interface TweetDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *retweetedImage;
@property (weak, nonatomic) IBOutlet UILabel *retweetedLabel;

// constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImageViewTopConstraint;

- (IBAction)onTapGesture:(UITapGestureRecognizer *)sender;

@end

@implementation TweetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Tweet";
    
    [self initElementsFromTweet:self.tweet];
    
    // place under the nav bar
    id topGuide = self.topLayoutGuide;
    
    if (self.tweet.retweetedStatus) {
        UIImageView *retweetedImage = self.retweetedImage;
        UILabel *retweetedLabel = self.retweetedLabel;
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(retweetedImage, retweetedLabel, topGuide);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-8-[retweetedImage]" options:0 metrics:nil views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-8-[retweetedLabel]" options:0 metrics:nil views:viewsDictionary]];
    } else {
        // remove the retweet icon and "xyz retweeted" label
        self.retweetedImage.frame = CGRectMake(0, 0, 0, 0);
        self.retweetedLabel.frame = CGRectMake(0, 0, 0, 0);
        [self.retweetedImage removeFromSuperview];
        [self.retweetedLabel removeFromSuperview];
        
        UIImageView *userImageView = self.userImageView;
        UILabel *usernameLabel = self.usernameLabel;
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(userImageView, usernameLabel, topGuide);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-8-[userImageView]" options:0 metrics:nil views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-32-[usernameLabel]" options:0 metrics:nil views:viewsDictionary]];
        
        [self removeConstraintsForView:self.retweetedImage];
        [self removeConstraintsForView:self.retweetedLabel];
        self.usernameLabelTopConstraint.active = NO;
        self.userImageViewTopConstraint.active = NO;
    }
    
    // add observers to automatically update favorite and retweet count
    [self.tweet addObserver:self forKeyPath:@"favoriteCount" options:NSKeyValueObservingOptionNew context:NULL];
    [self.tweet addObserver:self forKeyPath:@"retweetCount" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initElementsFromTweet:(Tweet *)tweet {
    Tweet *actualTweet = tweet;
    
    if (tweet.retweetedStatus) {
        actualTweet = tweet.retweetedStatus;
        self.retweetedLabel.text = [NSString stringWithFormat:@"%@ retweeted", tweet.author.name];
    }
    
    self.nameLabel.text = actualTweet.author.name;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", actualTweet.author.username];
    self.tweetLabel.text = actualTweet.text;
    
    [self setLabel:self.retweetCountLabel withInteger:actualTweet.retweetCount];
    [self setLabel:self.favoriteCountLabel withInteger:actualTweet.favoriteCount];
    
    self.userImageView.layer.cornerRadius = 3;
    self.userImageView.clipsToBounds = YES;
    NSURL *profileImageURL = [NSURL URLWithString:actualTweet.author.profileImageURL];
    [self.userImageView setImageWithURL:profileImageURL];
    
    [self.favoriteButton setBackgroundImage:[self imageForAction:@"favorite" on:actualTweet.isFavorited] forState:UIControlStateNormal];
    [self.retweetButton setBackgroundImage:[self imageForAction:@"retweet" on:actualTweet.isRetweeted] forState:UIControlStateNormal];
    if (actualTweet.isRetweeted || [actualTweet authorIsUser:[User currentUser]]) {
        self.retweetButton.enabled = NO;
    }
    
    [self formatTimestampLabel];
}

- (IBAction)onReplyButton:(id)sender {
    [self.tweetActionDelegate replyToTweet:[self.tweet actualTweet] sender:self];
}

- (IBAction)onRetweetButton:(id)sender {
    Tweet *actualTweet = [self.tweet actualTweet];
    if (actualTweet.isRetweeted) {
        // if the tweet was already retweeted by this user, do nothing
        return;
    }
    
    [self.retweetButton setBackgroundImage:[self imageForAction:@"retweet" on:YES] forState:UIControlStateNormal];
    self.retweetButton.enabled = NO;
    [self.tweetActionDelegate retweetTweet:actualTweet sender:self];
}

- (IBAction)onFavoriteButton:(id)sender {
    Tweet *actualTweet = [self.tweet actualTweet];
    BOOL wasFavorited = actualTweet.isFavorited;
    [self.favoriteButton setBackgroundImage:[self imageForAction:@"favorite" on:!wasFavorited] forState:UIControlStateNormal];
    [self.tweetActionDelegate favoriteForTweet:actualTweet sender:self];
}

- (UIImage *)imageForAction:(NSString *)action on:(BOOL)on {
    NSString *suffix = @"default";
    if (on) {
        suffix = @"on";
    }
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@", action, suffix]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    Tweet *tweet = (Tweet *)object;
    if ([keyPath isEqualToString:@"favoriteCount"]) {
        [self setLabel:self.favoriteCountLabel withInteger:tweet.favoriteCount];
    } else if ([keyPath isEqualToString:@"retweetCount"]) {
        [self setLabel:self.retweetCountLabel withInteger:tweet.retweetCount];
    }
}

- (void)setLabel:(UILabel *)label withInteger:(NSInteger)integer {
    label.text = [NSString stringWithFormat:@"%ld", (long)integer];
}

- (void)formatTimestampLabel {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"M/d/yy, h:mm a";
    
    self.timestampLabel.text = [formatter stringFromDate:self.tweet.createdAt];
}

- (void)removeConstraintsForView:(UIView *)view {
    for (NSLayoutConstraint *constraint in view.constraints) {
        constraint.active = NO;
    }
}

- (IBAction)onTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.view == self.userImageView) {
        ProfileViewController *pvc = [[ProfileViewController alloc] init];
        pvc.user = self.tweet.author;
        
        [self.navigationController pushViewController:pvc animated:YES];
    }
}

@end
