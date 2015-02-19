//
//  TwitterClient.m
//  Twitter
//
//  Created by Calvin Tuong on 2/17/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "TwitterClient.h"
#import "Tweet.h"

NSString * const kTwitterBaseURL = @"https://api.twitter.com";
NSString * const kTwitterRequestTokenPath = @"oauth/request_token";
NSString * const kTwitterAccessTokenPath = @"oauth/access_token";
NSString * const kTwitterUserVerifyCredentialsPath = @"1.1/account/verify_credentials.json";
NSString * const kTwitterHomeTimelinePath = @"1.1/statuses/home_timeline.json";

@interface TwitterClient ()

@property (nonatomic, strong) void (^loginCompletion)(User *user, NSError *error);

@end

@implementation TwitterClient

+ (TwitterClient *)sharedInstance {
    static TwitterClient *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"]];
            
            NSString *twitterConsumerKey = config[@"twitterConsumerKey"];
            NSString *twitterConsumerSecret = config[@"twitterConsumerSecret"];
            
            instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseURL] consumerKey:twitterConsumerKey consumerSecret:twitterConsumerSecret];
        }
    });
    
    return instance;
}

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion {
    self.loginCompletion = completion;
    
    [self.requestSerializer removeAccessToken];
    [self fetchRequestTokenWithPath:kTwitterRequestTokenPath method:@"GET" callbackURL:[NSURL URLWithString:@"ctuongtwitter://oauth"] scope:nil success:^(BDBOAuth1Credential *requestToken) {
        NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
        [[UIApplication sharedApplication] openURL:authURL];
    } failure:^(NSError *error) {
        NSLog(@"failed to get the request token");
        self.loginCompletion(nil, error);
    }];
}

- (void)openURL:(NSURL *)url {
    [self fetchAccessTokenWithPath:kTwitterAccessTokenPath method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential *accessToken) {
        [self.requestSerializer saveAccessToken:accessToken];
        
        [self GET:kTwitterUserVerifyCredentialsPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            User *user = [[User alloc] initWithDictionary:responseObject];
            [User setCurrentUser:user];
            self.loginCompletion(user, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failed to get current user");
            self.loginCompletion(nil, error);
        }];
        
//        [[TwitterClient sharedInstance] GET:@"1.1/statuses/home_timeline.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSArray *tweets = [Tweet tweetsWithArray:responseObject];
//            for (Tweet *tweet in tweets) {
//                NSLog(@"tweet: %@, created: %@", tweet.text, tweet.createdAt);
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"failed to get tweets");
//        }];
    } failure:^(NSError *error) {
        NSLog(@"failed to get the access token");
        self.loginCompletion(nil, error);
    }];
}

- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    [self GET:kTwitterHomeTimelinePath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

@end
