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
#import "SettingViewController.h"

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
    //获取固件版本
    __weak typeof(self) weakSelf = self;
    [FirmwareModel fetchListSuccess:^(id data) {
        
        self.dataArray = data;
        if (self.dataArray.count == 0) {
            //提示
            [weakSelf showTipWithMessage:@"There is no firmware available" withTitle:@"" useCancel:NO onOKBlock:nil];
        }
        
        self.tableConfig.items = self.dataArray;
        [self.firmwareTableView reloadData];
    } failure:^(id error) {
        [weakSelf showTipWithMessage:@"There is no firmware available" withTitle:@"" useCancel:NO onOKBlock:nil];
    }];
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
    //校验版本
    __weak typeof(self) weakSelf = self;
    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand checkVersionCommand:model.version] onRespond:^BOOL(NSData *data) {
        
        Byte value[2] = {0};
        [data getBytes:&value length:sizeof(value)];
        
        if (value[0] == 0xaa && value[1] == 0x0a) {
            
            [weakSelf showMessage:@"The new firmware is available,do you want to update?" withTitle:@"" cancleTitle:@"NO" cancel:^ {
                
                //返回主页
                [weakSelf popToViewControllerClass:[SettingViewController class] animated:YES];
                
            } okTitle:@"YES" onOKBlock:^{
                
                FirmwareService *service = [[FirmwareService alloc] initWithPeripheralIdentifier:self.light.identifier url:model.url completionHandler:^{
                    //更新完成
                }];
                
                [service startUpdating];    //开始更新
            }];
            
            return YES;
        }
        else if (value[0] == 0xaa && value[1] == 0xee) {
            [weakSelf showTipWithMessage:@"There is no firmware available" withTitle:@"" useCancel:NO onOKBlock:nil];
            return YES;
        }
        
        return NO;
        
    } timeOutValue:3.0 onTimeOut:^{
        
        [weakSelf showTipWithMessage:@"There is no firmware available" withTitle:@"" useCancel:NO onOKBlock:nil];
        
//        [weakSelf showMessage:@"The new firmware is available,do you want to update?" withTitle:@"" cancleTitle:@"NO" cancel:^ {
//            [weakSelf popToViewControllerClass:[SettingViewController class] animated:YES];
//
//        } okTitle:@"YES" onOKBlock:^{
//
//            FirmwareService *service = [[FirmwareService alloc] initWithPeripheralIdentifier:self.light.identifier url:model.url completionHandler:^{
//                //更新完成
//            }];
//
//            [service startUpdating];    //开始更新
//        }];
        
    }];
    
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
