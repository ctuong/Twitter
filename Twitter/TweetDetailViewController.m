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

@end

@implementation TweetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initElementsFromTweet:self.tweet];
    
    // place under the nav bar
    id topGuide = self.topLayoutGuide;
    UIImageView *retweetedImage = self.retweetedImage;
    UILabel *retweetedLabel = self.retweetedLabel;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(retweetedImage, retweetedLabel, topGuide);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-8-[retweetedImage]" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-8-[retweetedLabel]" options:0 metrics:nil views:viewsDictionary]];
    
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
    } else {
        // TODO remove the retweeted icon and label
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
    
    [self.tweetActionDelegate retweetTweet:actualTweet sender:self];
    [self.retweetButton setBackgroundImage:[self imageForAction:@"retweet" on:YES] forState:UIControlStateNormal];
    self.retweetButton.enabled = NO;
}

- (IBAction)onFavoriteButton:(id)sender {
    Tweet *actualTweet = [self.tweet actualTweet];
    BOOL wasFavorited = actualTweet.isFavorited;
    [self.tweetActionDelegate favoriteForTweet:actualTweet sender:self];
    [self.favoriteButton setBackgroundImage:[self imageForAction:@"favorite" on:!wasFavorited] forState:UIControlStateNormal];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
