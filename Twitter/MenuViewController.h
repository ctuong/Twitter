//
//  MenuViewController.h
//  Twitter
//
//  Created by Calvin Tuong on 2/27/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuViewController;

@protocol MenuViewControllerDelegate <NSObject>

- (void)profileViewSelected;
- (void)homeTimelineViewSelected;
- (void)mentionsViewSelected;
- (void)accountsViewSelected;
- (void)signOutViewSelected;

@end

@interface MenuViewController : UIViewController

@property (weak, nonatomic) id<MenuViewControllerDelegate> delegate;

@end
