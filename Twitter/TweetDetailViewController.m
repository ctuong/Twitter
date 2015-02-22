//
//  TweetDetailViewController.m
//  Twitter
//
//  Created by Calvin Tuong on 2/22/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "TweetDetailViewController.h"
#import <UIImageView+AFNetworking.h>

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
    self.retweetCountLabel.text = [actualTweet.retweetCount stringValue];
    self.favoriteCountLabel.text = [actualTweet.favoriteCount stringValue];
    
    self.userImageView.layer.cornerRadius = 3;
    self.userImageView.clipsToBounds = YES;
    NSURL *profileImageURL = [NSURL URLWithString:actualTweet.author.profileImageURL];
    [self.userImageView setImageWithURL:profileImageURL];
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
