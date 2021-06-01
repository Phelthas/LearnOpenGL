//
//  LXMDemoListViewController.m
//  Demo_OpenGLES_1
//
//  Created by billthaslu on 2021/5/31.
//  Copyright © 2021 lxm. All rights reserved.
//

#import "LXMDemoListViewController.h"
#import "LXMDemoEntranceModel.h"

@interface LXMDemoListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LXMDemoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];

}

- (void)setupUI {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        LXMDemoEntranceModel *model = self.dataArray[indexPath.row];
        cell.textLabel.text = model.entranceName;
        cell.detailTextLabel.text = model.desc;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LXMDemoEntranceModel *model = self.dataArray[indexPath.row];
    if (model.actionBlock) {
        model.actionBlock(self.navigationController);
    }
}

@end
