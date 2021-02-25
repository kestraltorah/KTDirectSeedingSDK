//

// KTVideoViewController.m
// KTDirectSeedingSDK_Example

// Created by KestralTorah (郭炜) on 2021/2/24
// E-mail: guowei@huami.com
// Copyright © 2021 kestraltorah@163.com. All rights reserved.

    

#import "KTVideoViewController.h"
#import "KTCaptureViewController.h"

static NSString *kCellIdentify = @"KTViewControllerCell";

@interface KTVideoViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation KTVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeViews];
}

#pragma mark -- 初始化界面
- (void)initializeViews {
    self.title = @"视频";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
}

#pragma mark -- tableView delegate&dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentify];
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            /// 摄像头采集数据
            [self.navigationController pushViewController:[KTCaptureViewController new] animated:YES];
        }
            break;
        case 1:
        case 2:
        case 3:

        default:
            break;
    }
}

#pragma mark -- 懒加载
- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[@"摄像头采集数据", @"视频编解码", @"编解码", @""];
    }
    return _dataSource;
}

@end
