//
//  FirmwareListViewController.m
//  VLCController
//
//  Created by mojingyu on 2017/7/9.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "FirmwareListViewController.h"
#import "LTTableViewConfig.h"
#import "FirmwareTableViewCell.h"
#import "FirmwareService.h"
#import "FirmwareModel.h"

@interface FirmwareListViewController ()

@property (nonatomic, strong) UITableView *firmwareTableView;
@property (nonatomic, strong) LTTableViewConfig *tableConfig;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation FirmwareListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Update Firmware";
    
    [self.view addSubview:self.firmwareTableView];
    [self.firmwareTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(NavBarHeight);
    }];
    
    [self setupTableConfig];
    [self loadDataFromService];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDataFromService
{
    [FirmwareModel fetchListSuccess:^(id data) {
        
        self.dataArray = data;
        self.tableConfig.items = self.dataArray;
        [self.firmwareTableView reloadData];
    } failure:nil];
}

- (void)setupTableConfig
{
//    __weak typeof(self) weakSelf = self;
    self.tableConfig = [[LTTableViewConfig alloc] initWithItems:self.dataArray registerCellBlock:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath, id item) {
        
        return [FirmwareTableViewCell registerTabelView:tableView forIndexPath:indexPath];
        
    } configureCellBlock:^(NSIndexPath *indexPath, id cell, id item) {
        
        [cell configure:cell custimObj:item indexPath:indexPath];
    } cellHeightBlock:^CGFloat(NSIndexPath *indexPath, id item) {
        
        return [FirmwareTableViewCell getCellHeightWitCustomObj:item indexPath:indexPath];
        
    } didSelectBlock:^(NSIndexPath *indexPath, id cell, id item) {
        
        FirmwareModel *model = item;
        [self startFirmwareUpdate:model];
    }];
    
    //设置代理
    [self.tableConfig handleTableViewDataSourceAndDelegate:self.firmwareTableView];
}

#pragma mark - Handle

- (void)startFirmwareUpdate:(FirmwareModel *)model
{
    FirmwareService *service = [[FirmwareService alloc] initWithPeripheralIdentifier:self.light.identifier url:model.url completionHandler:^{

        //更新完成

    }];

    [service startUpdating];    //开始更新
}

#pragma mark - Getter
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (UITableView *)firmwareTableView
{
    if (!_firmwareTableView) {
        _firmwareTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _firmwareTableView.backgroundColor = BlueColor;
        _firmwareTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return _firmwareTableView;
}

@end