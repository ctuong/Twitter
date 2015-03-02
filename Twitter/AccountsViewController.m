//
//  AccountsViewController.m
//  Twitter
//
//  Created by Calvin Tuong on 3/1/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "AccountsViewController.h"
#import "AccountCell.h"
#import "TwitterClient.h"
#import "ContainerViewController.h"
#import "LoginViewController.h"

@interface AccountsViewController () <UITableViewDataSource, UITableViewDelegate, AccountCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *accounts;

@end

@implementation AccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id topGuide = self.topLayoutGuide;
    UITableView *tableView = self.tableView;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(tableView, topGuide);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0-[tableView]" options:0 metrics:nil views:viewsDictionary]];

    self.accounts = [User allUsers];
        
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 125;
    [self.tableView registerNib:[UINib nibWithNibName:@"AccountCell" bundle:nil] forCellReuseIdentifier:@"AccountCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.accounts.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountCell" forIndexPath:indexPath];
    
    // change the default margin of the table divider length
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        cell.preservesSuperviewLayoutMargins = NO;
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    if (indexPath.row < self.accounts.count) {
        cell.user = self.accounts[indexPath.row];
        cell.addNewCell = NO;
    } else {
        cell.addNewCell = YES;
    }
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < self.accounts.count) {
        User *newUser = self.accounts[indexPath.row];
        [User setCurrentUser:newUser];
        ContainerViewController *cvc = [[ContainerViewController alloc] init];
        [self presentViewController:cvc animated:YES completion:nil];
    } else {
        [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
            if (user) {
                ContainerViewController *cvc = [[ContainerViewController alloc] init];
                [self presentViewController:cvc animated:YES completion:nil];
            } else {
                NSLog(@"Error logging in: %@", error);
            }
        }];
    }
}

#pragma mark - AccountCellDelegate methods

- (void)accountCell:(AccountCell *)accountCell didRemoveUser:(User *)user {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:accountCell];
    NSMutableArray *accounts = [self.accounts mutableCopy];
    [accounts removeObjectAtIndex:indexPath.row];
    self.accounts = accounts;
    [user removeFromUsers];
    
    if (self.accounts.count == 0) {
        // no accounts left, show login screen
        LoginViewController *lvc = [[LoginViewController alloc] init];
        [self presentViewController:lvc animated:YES completion:nil];
    } else {
        [self.tableView reloadData];
    }
}

@end
