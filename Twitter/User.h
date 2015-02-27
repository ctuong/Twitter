//
//  User.h
//  Twitter
//
//  Created by Calvin Tuong on 2/18/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const UserDidLoginNotification;
extern NSString * const UserDidLogoutNotification;

@interface User : NSObject

@property (nonatomic, assign) long long userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *profileImageURL;
@property (nonatomic, strong) NSString *profileBackgroundImageURL;
@property (nonatomic, strong) NSString *tagline;
@property (nonatomic, assign) long tweetCount;
@property (nonatomic, assign) long followingCount;
@property (nonatomic, assign) long followerCount;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (User *)currentUser;
+ (void)setCurrentUser:(User *)currentUser;
+ (void)logout;

@end
