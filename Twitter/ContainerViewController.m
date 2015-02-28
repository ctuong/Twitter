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
#import "MenuViewController.h"

@interface ContainerViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (nonatomic, strong) ProfileViewController *profileViewController;
@property (nonatomic, strong) TweetsViewController *tweetsViewController;
@property (nonatomic, strong) MenuViewController *menuViewController;

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
    self.tweetsViewController = [[TweetsViewController alloc] init];
    self.menuViewController = [[MenuViewController alloc] init];
    
    // initialize the content view
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:self.tweetsViewController];
    
    // nav bar settings
    nvc.navigationBar.barTintColor = [UIColor colorWithRed:(float)64/255 green:(float)153/255 blue:1 alpha:1];
    // make all text white
    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:@[[UIColor colorWithWhite:1 alpha:1]] forKeys:@[NSForegroundColorAttributeName]];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    [self addChildViewController:nvc];
    nvc.view.frame = self.contentView.frame;
    [self.contentView addSubview:nvc.view];
    [nvc didMoveToParentViewController:self];
    
    // initalize the menu view
    UINavigationController *menuNVC = [[UINavigationController alloc] initWithRootViewController:self.menuViewController];
    menuNVC.navigationBar.barTintColor = [UIColor colorWithRed:(float)64/255 green:(float)153/255 blue:1 alpha:1];
    
    [self addChildViewController:menuNVC];
    menuNVC.view.frame = self.menuView.frame;
    [self.menuView addSubview:menuNVC.view];
    [menuNVC didMoveToParentViewController:self];
    
    self.menuViewOpen = NO;
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        }
        [self.view needsUpdateConstraints];
        
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {}];
    }
}

- (void)onTapGesture:(UITapGestureRecognizer *)sender {
    if (self.menuViewOpen == YES) {
        [self openMenuView:NO];
        [self.view needsUpdateConstraints];
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {}];
    }
}

// set the menu view to be open
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
