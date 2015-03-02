//
//  AccountsViewController.m
//  Twitter
//
//  Created by Calvin Tuong on 3/1/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "AccountsViewController.h"
#import "AccountCell.h"

@interface AccountsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *accounts;

@end

@implementation AccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.accounts = [User allUsers];
        
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AccountCell" bundle:nil] forCellReuseIdentifier:@"AccountCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountCell" forIndexPath:indexPath];
    
    cell.user = self.accounts[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
