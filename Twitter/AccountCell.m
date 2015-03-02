//
//  AccountCell.m
//  Twitter
//
//  Created by Calvin Tuong on 3/1/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "AccountCell.h"

@interface AccountCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end

@implementation AccountCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(User *)user {
    self.nameLabel.text = user.name;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.username];
}

@end
