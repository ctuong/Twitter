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
    
    self.nameLabel.text = tweet.author.name;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", tweet.author.username];
    self.tweetLabel.text = tweet.text;
    
    self.userImageView.layer.cornerRadius = 3;
    self.userImageView.clipsToBounds = YES;
    NSURL *profileImageURL = [NSURL URLWithString:tweet.author.profileImageURL];
    [self.userImageView setImageWithURL:profileImageURL];
}

@end
