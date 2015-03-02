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

@property (weak, nonatomic) IBOutlet UIView *contentContainer;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *addNewImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTrailingConstraint;

@end

@implementation AccountCell

- (void)awakeFromNib {
    // Initialization code
    self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
    self.usernameLabel.preferredMaxLayoutWidth = self.usernameLabel.frame.size.width;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    [self addGestureRecognizer:panGesture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(User *)user {
    _user = user;
    [self.userImageView setImageWithURL:[NSURL URLWithString:user.profileImageURL]];
    self.userImageView.layer.cornerRadius = 3;
    self.userImageView.clipsToBounds = YES;
    self.nameLabel.text = user.name;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.username];
    self.contentView.backgroundColor = user.profileBackgroundColor;
    self.contentContainer.backgroundColor = user.profileBackgroundColor;
}

- (void)setAddNewCell:(BOOL)addNewCell {
    _addNewCell = addNewCell;
    if (self.isAddNewCell) {
        self.contentContainer.hidden = YES;
        self.userImageView.hidden = YES;
        self.nameLabel.hidden = YES;
        self.usernameLabel.hidden = YES;
        self.addNewImage.hidden = NO;
        self.contentView.backgroundColor = [UIColor colorWithRed:(170 / 255.0) green:(170 / 255.0) blue:(170 / 255.0) alpha:1];
    } else {
        self.contentContainer.hidden = NO;
        self.userImageView.hidden = NO;
        self.nameLabel.hidden = NO;
        self.usernameLabel.hidden = NO;
        self.addNewImage.hidden = YES;
    }
    
    self.contentLeadingConstraint.constant = 0;
    self.contentTrailingConstraint.constant = 0;
}

- (void)onPanGesture:(UIPanGestureRecognizer *)sender {
    if (self.isAddNewCell) {
        return;
    }
    
    CGFloat xTranslation = [sender translationInView:self.contentView].x;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        // do nothing
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        self.contentLeadingConstraint.constant = xTranslation;
        self.contentTrailingConstraint.constant = -xTranslation;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if (xTranslation > 100) {
            // if the pan gesture has moved more than 100px, remove the user
            [self.delegate accountCell:self didRemoveUser:self.user];
        } else {
            // otherwise, return it to normal
            self.contentLeadingConstraint.constant = 0;
            self.contentTrailingConstraint.constant = 0;
            [self.contentContainer needsUpdateConstraints];
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
                [self.contentContainer layoutIfNeeded];
            } completion:^(BOOL finished) {}];
        }
    }
}

@end
