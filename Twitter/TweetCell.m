//
//  TweetCell.m
//  Twitter
//
//  Created by Calvin Tuong on 2/19/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"

#define kSecondsInMinute 60
#define kSecondsInHour 3600
#define kSecondsInDay 86400
#define kSecondsInWeek 604800

@interface TweetCell ()

@property (weak, nonatomic) IBOutlet UIImageView *retweetedImage;
@property (weak, nonatomic) IBOutlet UILabel *retweetedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetedImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetedLabelHeightConstraint;

- (IBAction)onTapGesture:(UITapGestureRecognizer *)sender;

@end

@implementation TweetCell

- (void)awakeFromNib {
    // Initialization code
    
    self.tweetLabel.preferredMaxLayoutWidth = self.tweetLabel.frame.size.width;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    [self.userImageView addGestureRecognizer:tapGesture];
    self.userImageView.userInteractionEnabled = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    
    self.userImageView.layer.cornerRadius = 3;
    self.userImageView.clipsToBounds = YES;
    
    Tweet *actualTweet = tweet;
    
    if (tweet.retweetedStatus) {
        actualTweet = tweet.retweetedStatus;
        self.retweetedLabel.text = [NSString stringWithFormat:@"%@ retweeted", tweet.author.name];
        self.retweetedLabelHeightConstraint.constant = 10.f;
        self.retweetedImageHeightConstraint.constant = 16.f;
    } else {
        // remove the retweet icon and "xyz retweeted" label
        self.retweetedImageHeightConstraint.constant = 0.f;
        self.retweetedLabelHeightConstraint.constant = 0.f;
    }
    
    self.nameLabel.text = actualTweet.author.name;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", actualTweet.author.username];
    self.tweetLabel.text = actualTweet.text;
    
    NSURL *profileImageURL = [NSURL URLWithString:actualTweet.author.profileImageURL];
    [self.userImageView setImageWithURL:profileImageURL];
    
    if (actualTweet.isRetweeted || [actualTweet authorIsUser:[User currentUser]]) {
        self.retweetButton.enabled = NO;
    } else {
        self.retweetButton.enabled = YES;
    }
    
    [self.retweetButton setBackgroundImage:[self imageForAction:@"retweet" on:actualTweet.isRetweeted] forState:UIControlStateNormal];
    [self.favoriteButton setBackgroundImage:[self imageForAction:@"favorite" on:actualTweet.isFavorited] forState:UIControlStateNormal];
    
    [self formatTweetTimeLabel];
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

}

- (IBAction)onFavoriteButton:(id)sender {
    Tweet *actualTweet = [self.tweet actualTweet];
    [self.tweetActionDelegate favoriteForTweet:actualTweet sender:self];
}

- (UIImage *)imageForAction:(NSString *)action on:(BOOL)on {
    NSString *suffix = @"default";
    if (on) {
        suffix = @"on";
    }
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@", action, suffix]];
}

- (void)formatTweetTimeLabel {
    NSDate *createdAt = self.tweet.createdAt;
    NSTimeInterval interval = createdAt.timeIntervalSinceNow;
    NSString *labelText;
    
    if (interval > -kSecondsInMinute) {
        labelText = [NSString stringWithFormat:@"%lds", (long)-interval];
    } else if (interval > -kSecondsInHour) {
        // less than an hour ago
        long num = (long)(-interval / kSecondsInMinute);
        labelText = [NSString stringWithFormat:@"%ldm", num];
    } else if (interval > -kSecondsInDay) {
        // less than a day ago
        long num = (long)(-interval / kSecondsInHour);
        labelText = [NSString stringWithFormat:@"%ldh", num];
    } else if (interval > -kSecondsInWeek) {
        // less than a week ago
        long num = (long)(-interval / kSecondsInDay);
        labelText = [NSString stringWithFormat:@"%ldd", num];
    } else {
        // just print the date
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"M/d/yy";
        
        labelText = [formatter stringFromDate:createdAt];
    }
    
    self.tweetTimeLabel.text = labelText;
}

- (void)removeConstraintsForView:(UIView *)view {
    for (NSLayoutConstraint *constraint in view.constraints) {
        constraint.active = NO;
    }
}

- (IBAction)onTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.view == self.userImageView) {
        if ([self.tweetActionDelegate respondsToSelector:@selector(userImageViewTappedForUser:)]) {
            [self.tweetActionDelegate userImageViewTappedForUser:self.tweet.author];
        }
    }
}

@end
