//
//  AccountCell.m
//  Twitter
//
//  Created by Calvin Tuong on 3/1/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "AccountCell.h"
#import <UIImageView+AFNetworking.h>

@interface AccountCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *addNewImage;

@end

@implementation AccountCell

- (void)awakeFromNib {
    // Initialization code
    self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
    self.usernameLabel.preferredMaxLayoutWidth = self.usernameLabel.frame.size.width;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(User *)user {
    [self.userImageView setImageWithURL:[NSURL URLWithString:user.profileImageURL]];
    self.userImageView.layer.cornerRadius = 3;
    self.userImageView.clipsToBounds = YES;
    self.nameLabel.text = user.name;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.username];
}

- (void)setAddNewCell:(BOOL)addNewCell {
    _addNewCell = addNewCell;
    if (self.isAddNewCell) {
        self.userImageView.hidden = YES;
        self.nameLabel.hidden = YES;
        self.usernameLabel.hidden = YES;
        self.addNewImage.hidden = NO;
    } else {
        self.userImageView.hidden = NO;
        self.nameLabel.hidden = NO;
        self.usernameLabel.hidden = NO;
        self.addNewImage.hidden = YES;
    }
}

@end
