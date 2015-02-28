//
//  MenuViewController.m
//  Twitter
//
//  Created by Calvin Tuong on 2/27/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet UIView *homeView;
@property (weak, nonatomic) IBOutlet UIView *mentionsView;
@property (weak, nonatomic) IBOutlet UIView *signOutView;

- (IBAction)onTapGesture:(UITapGestureRecognizer *)sender;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // place under the nav bar
    id topGuide = self.topLayoutGuide;
    UIView *profileView = self.profileView;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(profileView, topGuide);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0-[profileView]" options:0 metrics:nil views:viewsDictionary]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTapGesture:(UITapGestureRecognizer *)sender {
    // show the proper view, collapse the menu
    // probably delegate
    if (sender.view == self.profileView) {
        [self.delegate profileViewSelected];
    } else if (sender.view == self.homeView) {
        [self.delegate homeTimelineViewSelected];
    } else if (sender.view == self.mentionsView) {
        [self.delegate mentionsViewSelected];
    } else if (sender.view == self.signOutView) {
        [self.delegate signOutViewSelected];
    }
}

@end
