//
//  NewTweetViewController.h
//  Twitter
//
//  Created by Calvin Tuong on 2/22/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class NewTweetViewController;

@protocol NewTweetViewControllerDelegate <NSObject>

@optional
- (void)newTweetViewController:(NewTweetViewController *)newTweetViewController didPostTweet:(Tweet *)tweet;

@end

@interface NewTweetViewController : UIViewController

@property (weak, nonatomic) id<NewTweetViewControllerDelegate> delegate;

@end
