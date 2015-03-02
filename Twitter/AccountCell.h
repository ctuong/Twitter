//
//  AccountCell.h
//  Twitter
//
//  Created by Calvin Tuong on 3/1/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface AccountCell : UITableViewCell

@property (nonatomic, strong) User *user;
@property (nonatomic, assign, getter=isAddNewCell) BOOL addNewCell;

@end
