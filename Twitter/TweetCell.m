//
//  TweetCell.m
//  Twitter
//
//  Created by Calvin Tuong on 2/19/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"

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

@end

@implementation TweetCell

- (void)awakeFromNib {
    // Initialization code
    
    self.tweetLabel.preferredMaxLayoutWidth = self.tweetLabel.frame.size.width;
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
    } else {
        // TODO remove the retweeted icon and label
    }
    
    self.nameLabel.text = actualTweet.author.name;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", actualTweet.author.username];
    self.tweetLabel.text = actualTweet.text;
    
    NSURL *profileImageURL = [NSURL URLWithString:actualTweet.author.profileImageURL];
    [self.userImageView setImageWithURL:profileImageURL];
}

@end
