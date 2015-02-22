//
//  LoginViewController.m
//  Twitter
//
//  Created by Calvin Tuong on 2/17/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "LoginViewController.h"
#import "TwitterClient.h"
#import "TweetsViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Login";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogin:(id)sender {
    [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
        if (user) {
            // Modally present the tweets view
            TweetsViewController *tvc = [[TweetsViewController alloc] init];
            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:tvc];
            // nav bar settings
            nvc.navigationBar.barTintColor = [UIColor colorWithRed:(float)64/255 green:(float)153/255 blue:1 alpha:1];
            // make all text white
            NSDictionary *attributes = [NSDictionary dictionaryWithObjects:@[[UIColor colorWithWhite:1 alpha:1]] forKeys:@[NSForegroundColorAttributeName]];
            [[UINavigationBar appearance] setTitleTextAttributes:attributes];
            
            [self presentViewController:nvc animated:YES completion:nil];
        } else {
            NSLog(@"Error logging in: %@", error);
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
