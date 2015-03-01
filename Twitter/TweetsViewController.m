//
//  TweetsViewController.m
//  Twitter
//
//  Created by Calvin Tuong on 2/28/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "TweetsViewController.h"
#import "TweetListViewControllerPrivate.h"

@interface TweetsViewController ()

@end

@implementation TweetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Home";
    
    // set up the nav bar button
    UIBarButtonItem *newTweetButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onNewTweetButton)];
    newTweetButton.tintColor = [UIColor colorWithWhite:1 alpha:1];
    self.navigationItem.rightBarButtonItem = newTweetButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)onNewTweetButton {
    NewTweetViewController *ntvc = [[NewTweetViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:ntvc];
    ntvc.delegate = self;
    
    [self presentViewController:nvc animated:YES completion:nil];
}

@end
