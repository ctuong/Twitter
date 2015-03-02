//
//  ContainerViewController.m
//  Twitter
//
//  Created by Calvin Tuong on 2/27/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "ContainerViewController.h"
#import "TweetsViewController.h"
#import "ProfileViewController.h"
#import "MentionsViewController.h"
#import "MenuViewController.h"
#import "AccountsViewController.h"
#import "User.h"

@interface ContainerViewController () <MenuViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *menuView;

@property (nonatomic, strong) UINavigationController *profileViewNavigationController;
@property (nonatomic, strong) ProfileViewController *profileViewController;
@property (nonatomic, strong) UINavigationController *tweetsViewNavigationController;
@property (nonatomic, strong) TweetsViewController *tweetsViewController;
@property (nonatomic, strong) UINavigationController *mentionsViewNavigationController;
@property (nonatomic, strong) MentionsViewController *mentionsViewController;
@property (nonatomic, strong) AccountsViewController *accountsViewController;
@property (nonatomic, strong) UINavigationController *menuViewNavigationController;
@property (nonatomic, strong) MenuViewController *menuViewController;

@property (nonatomic, strong) UIViewController *currentContentViewController;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, assign) BOOL menuViewOpen;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewTrailingConstraint;

- (IBAction)onPanGesture:(UIPanGestureRecognizer *)sender;

@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.profileViewController = [[ProfileViewController alloc] init];
    self.profileViewController.user = [User currentUser];
    self.tweetsViewController = [[TweetsViewController alloc] initWithNibName:@"TweetListViewController" bundle:[NSBundle mainBundle]];
    self.mentionsViewController = [[MentionsViewController alloc] initWithNibName:@"TweetListViewController" bundle:[NSBundle mainBundle]];
    self.accountsViewController = [[AccountsViewController alloc] init];
    self.menuViewController = [[MenuViewController alloc] init];
    self.menuViewController.delegate = self;
    
    // initialize the home timeline view as the content view
    self.tweetsViewNavigationController = [[UINavigationController alloc] initWithRootViewController:self.tweetsViewController];
    
    // nav bar settings
    self.tweetsViewNavigationController.navigationBar.barTintColor = [UIColor colorWithRed:(float)64/255 green:(float)153/255 blue:1 alpha:1];
    // make all text white
    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:@[[UIColor colorWithWhite:1 alpha:1]] forKeys:@[NSForegroundColorAttributeName]];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    if (self.accountsViewShouldBeActive) {
        [self addCurrentContentViewController:self.accountsViewController];
    } else {
        [self addCurrentContentViewController:self.tweetsViewNavigationController];
    }
    
    // initalize the profile view
    self.profileViewNavigationController = [[UINavigationController alloc] initWithRootViewController:self.profileViewController];
    
    // nav bar settings
    self.profileViewNavigationController.navigationBar.barTintColor = [UIColor colorWithRed:(float)64/255 green:(float)153/255 blue:1 alpha:1];
    
    // initialize the mentions view
    self.mentionsViewNavigationController = [[UINavigationController alloc] initWithRootViewController:self.mentionsViewController];
    
    // nav bar settings
    self.mentionsViewNavigationController.navigationBar.barTintColor = [UIColor colorWithRed:(float)64/255 green:(float)153/255 blue:1 alpha:1];
    
    // initalize the menu view
    self.menuViewNavigationController = [[UINavigationController alloc] initWithRootViewController:self.menuViewController];
    self.menuViewNavigationController.navigationBar.barTintColor = [UIColor colorWithRed:(float)64/255 green:(float)153/255 blue:1 alpha:1];
    
    [self addChildViewController:self.menuViewNavigationController];
    self.menuViewNavigationController.view.frame = self.menuView.frame;
    [self.menuView addSubview:self.menuViewNavigationController.view];
    [self.menuViewNavigationController didMoveToParentViewController:self];
    
    self.menuViewOpen = NO;
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MenuViewControllerDelegate methods

- (void)profileViewSelected {
    [self removeCurrentContentViewController];
    [self animateCloseMenuView];
    [self addCurrentContentViewController:self.profileViewNavigationController];
}

- (void)homeTimelineViewSelected {
    [self removeCurrentContentViewController];
    [self animateCloseMenuView];
    [self addCurrentContentViewController:self.tweetsViewNavigationController];
}

- (void)mentionsViewSelected {
    [self removeCurrentContentViewController];
    [self animateCloseMenuView];
    [self addCurrentContentViewController:self.mentionsViewNavigationController];
}

- (void)accountsViewSelected {
    [self removeCurrentContentViewController];
    [self animateCloseMenuView];
    [self addCurrentContentViewController:self.accountsViewController];
}

- (void)signOutViewSelected {
    [self removeCurrentContentViewController];
    [User logout];
}

#pragma mark - Private methods

- (void)removeCurrentContentViewController {
    [self.currentContentViewController willMoveToParentViewController:nil];
    [self.currentContentViewController.view removeFromSuperview];
    [self.currentContentViewController removeFromParentViewController];
}

- (void)addCurrentContentViewController:(UIViewController *)viewController {
    [self addChildViewController:viewController];
    viewController.view.frame = self.contentView.frame;
    [self.contentView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    self.currentContentViewController = viewController;
}

- (IBAction)onPanGesture:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        // do nothing
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [sender translationInView:self.view];
        
        if ([sender velocityInView:self.view].x > 0 && self.menuViewOpen == NO) {
            // moving right and the menu isn't open
            self.contentViewLeadingConstraint.constant = translation.x;
            self.contentViewTrailingConstraint.constant = -translation.x;
        } else if ([sender velocityInView:self.view].x < 0 && self.menuViewOpen == YES) {
            // moving left and the menu is open
            CGSize menuViewSize = self.menuViewController.view.frame.size;
            self.contentViewLeadingConstraint.constant = menuViewSize.width + translation.x;
            self.contentViewTrailingConstraint.constant = -(menuViewSize.width + translation.x);
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        // go to final state
        if ([sender velocityInView:self.view].x > 0 && self.menuViewOpen == NO) {
            // moving right and menu view isn't open; open the menu view
            [self openMenuView:YES];
        } else if ([sender velocityInView:self.view].x < 0 && self.menuViewOpen == YES) {
            // moving left and menu view is open; collapse the menu view
            [self openMenuView:NO];
        } else if ([sender velocityInView:self.view].x == 0) {
            // if for some reason the gesture ended while still, make the state of the menu change
            [self openMenuView:!self.menuViewOpen];
        }
        [self.view needsUpdateConstraints];
        
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {}];
    }
}

- (void)onTapGesture:(UITapGestureRecognizer *)sender {
    [self animateCloseMenuView];
}

- (void)animateCloseMenuView {
    if (self.menuViewOpen == YES) {
        [self openMenuView:NO];
        [self.view needsUpdateConstraints];
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {}];
    }
}

// set the menu view to be open or closed
- (void)openMenuView:(BOOL)open {
    if (open) {
        CGSize menuViewSize = self.menuViewController.view.frame.size;
        self.contentViewLeadingConstraint.constant = menuViewSize.width;
        self.contentViewTrailingConstraint.constant = -menuViewSize.width;
        
        self.contentView.layer.shadowOffset = CGSizeMake(-5, 10);
        self.contentView.layer.shadowRadius = 3;
        self.contentView.layer.shadowOpacity = 0.2;
        
        self.menuViewOpen = YES;
        
        [self.contentView becomeFirstResponder];
        [self.contentView addGestureRecognizer:self.tapGesture];
    } else {
        self.contentViewLeadingConstraint.constant = 0;
        self.contentViewTrailingConstraint.constant = 0;
        self.menuViewOpen = NO;
        
        self.contentView.layer.shadowOffset = CGSizeMake(0, 0);
        self.contentView.layer.shadowRadius = 0;
        self.contentView.layer.shadowOpacity = 0;
        
        [self.contentView resignFirstResponder];
        [self.contentView removeGestureRecognizer:self.tapGesture];
    }
}

@end
