//
//  AppDelegate.m
//  Twitter
//
//  Created by Calvin Tuong on 2/17/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TweetsViewController.h"
#import "TwitterClient.h"
#import "User.h"
#import "Tweet.h"
#import "ContainerViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:UserDidLogoutNotification object:nil];
    
    UINavigationController *nvc;
    User *currentUser = [User currentUser];
    if (currentUser) {
        ContainerViewController *cvc = [[ContainerViewController alloc] init];
        self.window.rootViewController = cvc;
    } else {
        LoginViewController *lvc = [[LoginViewController alloc] init];
        nvc = [[UINavigationController alloc] initWithRootViewController:lvc];
        
        // nav bar settings
        nvc.navigationBar.barTintColor = [UIColor colorWithRed:(float)64/255 green:(float)153/255 blue:1 alpha:1];
        // make all text white
        NSDictionary *attributes = [NSDictionary dictionaryWithObjects:@[[UIColor colorWithWhite:1 alpha:1]] forKeys:@[NSForegroundColorAttributeName]];
        [[UINavigationBar appearance] setTitleTextAttributes:attributes];
        
        self.window.rootViewController = nvc;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)userDidLogout {
    NSArray *users = [User allUsers];
    if (users.count > 0) {
        // there are other users logged in, show the account picker page
        ContainerViewController *cvc = [[ContainerViewController alloc] init];
        cvc.accountsViewShouldBeActive = YES;
        self.window.rootViewController = cvc;
    } else {
        // otherwise, show login
        self.window.rootViewController = [[LoginViewController alloc] init];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[TwitterClient sharedInstance] openURL:url];
    
    return YES;
}

@end
