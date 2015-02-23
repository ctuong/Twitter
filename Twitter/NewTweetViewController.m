//
//  NewTweetViewController.m
//  Twitter
//
//  Created by Calvin Tuong on 2/22/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "NewTweetViewController.h"
#import <UIImageView+AFNetworking.h>
#import "User.h"
#import "TwitterClient.h"

#define kMaxTweetChars 140

@interface NewTweetViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (nonatomic, strong) UIBarButtonItem *tweetCounter;
@property (nonatomic, strong) UIBarButtonItem *tweetButton;

@end

@implementation NewTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // place the views under the nav bar
    id topGuide = self.topLayoutGuide;
    UIImageView *userImageView = self.userImageView;
    UILabel *nameLabel = self.nameLabel;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(userImageView, nameLabel, topGuide);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-8-[userImageView]" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-8-[nameLabel]" options:0 metrics:nil views:viewsDictionary]];

    
    // set up nav bar
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.tweetButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweetButton)];
    
    self.tweetCounter = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%ld", (long)kMaxTweetChars] style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tweetCounter.enabled = NO;
    self.tweetCounter.tintColor = [UIColor colorWithWhite:0.3 alpha:1];
    
    self.navigationItem.rightBarButtonItems = @[self.tweetButton, self.tweetCounter];
    
    User *user = [User currentUser];
    
    self.userImageView.layer.cornerRadius = 3;
    self.userImageView.clipsToBounds = YES;
    NSURL *imageURL = [NSURL URLWithString:user.profileImageURL];
    [self.userImageView setImageWithURL:imageURL];
    self.nameLabel.text = user.name;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.username];
    
    self.tweetTextView.delegate = self;
    self.tweetTextView.text = @"";
    
    if (self.inReplyToTweet) {
        self.tweetTextView.text = [NSString stringWithFormat:@"@%@ ", self.inReplyToTweet.author.username];
        [self updateTweetCounterWithRemaining:(kMaxTweetChars - self.tweetTextView.text.length)];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self.tweetTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView {
    NSInteger remaining = kMaxTweetChars - textView.text.length;
    [self updateTweetCounterWithRemaining:remaining];
}

#pragma mark - Private methods

- (void)onCancelButton {
    [self.tweetTextView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onTweetButton {
    NSString *tweetText = self.tweetTextView.text;
    
    NSDictionary *params = nil;
    if (self.inReplyToTweet) {
        params = [NSDictionary dictionaryWithObjects:@[@(self.inReplyToTweet.tweetId)] forKeys:@[@"in_reply_to_status_id"]];
    }
    
    [[TwitterClient sharedInstance] postTweet:tweetText params:params completion:^(Tweet *tweet, NSError *error) {
        if (error) {
            NSLog(@"Error posting tweet: %@", error);
        } else {
            // TODO pass this tweet back to the delegate, where it should update the placeholder tweet with this one
        }
    }];
    
    if ([self.delegate respondsToSelector:@selector(newTweetViewController:didPostTweet:)]) {
        // TODO create a placeholder tweet
        [self.delegate newTweetViewController:self didPostTweet:nil];
    }
    
    [self onCancelButton];
}

- (void)updateTweetCounterWithRemaining:(NSInteger)remaining {
    [UIView setAnimationsEnabled:NO];
    self.tweetCounter.title = [NSString stringWithFormat:@"%ld", remaining];
    
    if (remaining < 0) {
        // disable the tweet button
        self.tweetButton.enabled = NO;
    } else {
        self.tweetButton.enabled = YES;
    }
    [UIView setAnimationsEnabled:YES];
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
