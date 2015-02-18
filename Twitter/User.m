//
//  User.m
//  Twitter
//
//  Created by Calvin Tuong on 2/18/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "User.h"

@implementation User

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = dictionary[@"name"];
        self.username = dictionary[@"screen_name"];
        self.profileImageURL = dictionary[@"profile_image_url"];
        self.tagline = dictionary[@"description"];
    }
    
    return self;
}

@end
