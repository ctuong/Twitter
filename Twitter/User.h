//
//  User.h
//  Twitter
//
//  Created by Calvin Tuong on 2/18/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *profileImageURL;
@property (nonatomic, strong) NSString *tagline;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
