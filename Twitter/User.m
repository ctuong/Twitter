//
//  User.m
//  Twitter
//
//  Created by Calvin Tuong on 2/18/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";

@interface User ()

// used to restore and save the current user
@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) NSString *userIdString;

@end

@implementation User

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.dictionary = dictionary;
        
        self.userId = [dictionary[@"id"] longLongValue];
        self.userIdString = [NSString stringWithFormat:@"%lld", self.userId];
        self.name = dictionary[@"name"];
        self.username = dictionary[@"screen_name"];
        self.profileImageURL = dictionary[@"profile_image_url"];
        self.profileBackgroundImageURL = dictionary[@"profile_background_image_url"];
        self.profileBannerURL = dictionary[@"profile_banner_url"];
        self.profileBackgroundColor = [self colorFromHex:dictionary[@"profile_background_color"]];
        self.tagline = dictionary[@"description"];
        self.tweetCount = [dictionary[@"statuses_count"] longValue];
        self.followingCount = [dictionary[@"friends_count"] longValue];
        self.followerCount = [dictionary[@"followers_count"] longValue];
    }
    
    return self;
}

- (UIColor *)colorFromHex:(NSString *)hexString {
    unsigned int rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((float)((rgbValue & 0x00FF00) >>  8))/255.0
                            blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0
                           alpha:1];
}

- (void)removeFromUsers {
    if (self == [User currentUser]) {
        [User setCurrentUser:nil];
        [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    }
    
    [User removeUserFromStorage:self];
}

+ (NSArray *)usersWithArray:(NSArray *)array {
    NSMutableArray *users = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        [users addObject:[[User alloc] initWithDictionary:dictionary]];
    }
    
    return users;
}

static User *_currentUser = nil;

NSString * const kCurrentUserIdKey = @"kCurrentUserId";
NSString * const kCurrentUsersDictionaryKey = @"kCurrentUsersDictionary";
NSString * const kCurrentUsersCredentialsDictionaryKey = @"kCurrentUsersCredentials";

+ (User *)currentUser {
    if (!_currentUser) {
        NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentUserIdKey];
        if (userId) {
            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUsersDictionaryKey];
            if (data) {
                NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                NSDictionary *userDictionary = dictionary[userId];
                _currentUser = [[User alloc] initWithDictionary:userDictionary];
            }
        }
    }
    
    return _currentUser;
}

+ (void)setCurrentUser:(User *)currentUser {
    _currentUser = currentUser;
    
    if (_currentUser) {
        [[NSUserDefaults standardUserDefaults] setObject:_currentUser.userIdString forKey:kCurrentUserIdKey];
        [self addUserToStorage:_currentUser];
        // set the credentials to be those of the new current user
        [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
        [[TwitterClient sharedInstance].requestSerializer saveAccessToken:[_currentUser getCredential]];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCurrentUserIdKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// save the user dictionary to user defaults
+ (void)addUserToStorage:(User *)user {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUsersDictionaryKey];
    if (data) {
        // update the existing users dictionary with this user
        NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSMutableDictionary *updatedDictionary = [dictionary mutableCopy];
        [updatedDictionary setObject:user.dictionary forKey:user.userIdString];
        NSData *dataToStore = [NSKeyedArchiver archivedDataWithRootObject:updatedDictionary];
        [[NSUserDefaults standardUserDefaults] setObject:dataToStore forKey:kCurrentUsersDictionaryKey];
    } else {
        // initialize the current users dictionary key to be a dictionary with just this user
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:user.dictionary forKey:user.userIdString];
        NSData *dataToStore = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
        [[NSUserDefaults standardUserDefaults] setObject:dataToStore forKey:kCurrentUsersDictionaryKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// retrieve the user's credentials from user defaults
- (BDBOAuth1Credential *)getCredential {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUsersCredentialsDictionaryKey];
    if (data) {
        NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSData *credentialData = dictionary[self.userIdString];
        return [NSKeyedUnarchiver unarchiveObjectWithData:credentialData];
    }
    return nil;
}

// store the credentials to user defaults
- (void)storeCredential:(BDBOAuth1Credential *)credential {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUsersCredentialsDictionaryKey];
    // TODO might not need to archive credential data since archiving the whole dictionary
    NSData *credentialData = [NSKeyedArchiver archivedDataWithRootObject:credential];
    
    if (data) {
        // update the existing credentials dictionary with these credentials
        NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSMutableDictionary *updatedDictionary = [dictionary mutableCopy];
        [updatedDictionary setObject:credentialData forKey:self.userIdString];
        NSData *dataToStore = [NSKeyedArchiver archivedDataWithRootObject:updatedDictionary];
        [[NSUserDefaults standardUserDefaults] setObject:dataToStore forKey:kCurrentUsersCredentialsDictionaryKey];
    } else {
        // initialize the credentials dictionary key to be a dictionary with just these credentials
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:credentialData forKey:self.userIdString];
        NSData *dataToStore = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
        [[NSUserDefaults standardUserDefaults] setObject:dataToStore forKey:kCurrentUsersCredentialsDictionaryKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// removes the user from both the users dictionary and the credentials dictionary
+ (void)removeUserFromStorage:(User *)user {
    [self removeUser:user fromUserDefaultsKey:kCurrentUsersDictionaryKey];
    [self removeUser:user fromUserDefaultsKey:kCurrentUsersCredentialsDictionaryKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeUser:(User *)user fromUserDefaultsKey:(NSString *)key {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (data) {
        NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (dictionary[user.userIdString]) {
            NSMutableDictionary *updatedDictionary = [dictionary mutableCopy];
            [updatedDictionary removeObjectForKey:user.userIdString];
            NSData *dataToStore = [NSKeyedArchiver archivedDataWithRootObject:updatedDictionary];
            [[NSUserDefaults standardUserDefaults] setObject:dataToStore forKey:key];
        }
    }
}

+ (void)logout {
    [self removeUserFromStorage:_currentUser];
    [User setCurrentUser:nil];
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
}

+ (NSArray *)allUsers {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUsersDictionaryKey];
    if (data) {
        NSDictionary *users = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSArray *userDictionaries = [users allValues];
        return [self usersWithArray:userDictionaries];
    }
    return [NSArray array];
}

@end
