//
//  TwitterClient.m
//  Twitter
//
//  Created by Calvin Tuong on 2/17/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "TwitterClient.h"

NSString * const kTwitterBaseURL = @"https://api.twitter.com";
NSString * const kTwitterRequestTokenPath = @"oauth/request_token";
NSString * const kTwitterAccessTokenPath = @"oauth/access_token";
NSString * const kTwitterUserVerifyCredentialsPath = @"1.1/account/verify_credentials.json";
NSString * const kTwitterHomeTimelinePath = @"1.1/statuses/home_timeline.json";
NSString * const kTwitterUserTimelinePath = @"1.1/statuses/user_timeline.json";
NSString * const kTwitterMentionsTimelinePath = @"1.1/statuses/mentions_timeline.json";
NSString * const kTwitterPostTweetPath = @"1.1/statuses/update.json";
NSString * const kTwitterRetweetPath = @"1.1/statuses/retweet/%lld.json";
NSString * const kTwitterFavoriteCreatePath = @"1.1/favorites/create.json";
NSString * const kTwitterFavoriteDestroyPath = @"1.1/favorites/destroy.json";

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
            [user storeCredential:accessToken];
            [User setCurrentUser:user];
            self.loginCompletion(user, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failed to get current user");
            self.loginCompletion(nil, error);
        }];
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

- (void)userTimelineForUser:(User *)user params:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    NSDictionary *defaults = @{@"user_id": @(user.userId)};
    NSMutableDictionary *allParams = [defaults mutableCopy];
    if (params) {
        [allParams addEntriesFromDictionary:params];
    }
    
    [self GET:kTwitterUserTimelinePath parameters:allParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)mentionsTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    [self GET:kTwitterMentionsTimelinePath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)postTweet:(NSString *)tweet params:(NSDictionary *)params completion:(void (^)(Tweet *tweet, NSError *error))completion {
    NSString *inReplyToParam = @"";
    if (params[@"in_reply_to_status_id"]) {
        inReplyToParam = [NSString stringWithFormat:@"&in_reply_to_status_id=%lld", [params[@"in_reply_to_status_id"] longLongValue]];
    }
    NSString *unescapedUrlPath = [NSString stringWithFormat:@"%@?status=%@%@", kTwitterPostTweetPath, tweet, inReplyToParam];
    NSString *escapedUrlPath = [unescapedUrlPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self POST:escapedUrlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
        completion(tweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)retweetTweet:(Tweet *)tweet params:(NSDictionary *)params completion:(void (^)(Tweet *tweet, NSError *error))completion {
    NSString *path = [NSString stringWithFormat:kTwitterRetweetPath, tweet.tweetId];
    [self POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *retweet = [[Tweet alloc] initWithDictionary:responseObject];
        completion(retweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)favoriteTweet:(Tweet *)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion {
    NSDictionary *params = @{@"id" : @(tweet.tweetId)};
    [self POST:kTwitterFavoriteCreatePath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *returnedTweet = [[Tweet alloc] initWithDictionary:responseObject];
        completion(returnedTweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)unfavoriteTweet:(Tweet *)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion {
    NSDictionary *params = @{@"id" : @(tweet.tweetId)};
    [self POST:kTwitterFavoriteDestroyPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *returnedTweet = [[Tweet alloc] initWithDictionary:responseObject];
        completion(returnedTweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

@end
