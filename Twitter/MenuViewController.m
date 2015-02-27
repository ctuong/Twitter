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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTapGesture:(UITapGestureRecognizer *)sender {
    // show the proper view, collapse the menu
    // probably delegate
    if (sender.view == self.profileView) {
        
    } else if (sender.view == self.homeView) {
        
    } else if (sender.view == self.mentionsView) {
        
    } else if (sender.view == self.signOutView) {
        
    }
}

@end
