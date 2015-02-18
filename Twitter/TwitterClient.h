//
//  TwitterClient.h
//  Twitter
//
//  Created by Calvin Tuong on 2/17/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)sharedInstance;

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion;
- (void)openURL:(NSURL *)url;

@end