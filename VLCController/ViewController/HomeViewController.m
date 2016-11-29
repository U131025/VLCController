//
//  HomeViewController.m
//  VLCController
//
//  Created by mojingyu on 16/1/8.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "HomeViewController.h"
#import "LightControllerModel.h"
#import "LightControllerCellView.h"
#import "SettingViewController.h"
#import "NotFoundViewController.h"
#import "MBProgressHUD+NJ.h"
#import "FoundViewController.h"
#import "DuplicateControllerViewController.h"
#import "SlaveControllerViewController.h"

@interface HomeViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *lightControllerArray; // of LightControllerModel
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) LightControllerCellView *seletedCellView;
@property (nonatomic, assign) BOOL isCellEdit;

@property (nonatomic, assign) BOOL isReciveNotify;
@property (nonatomic, strong) LightControllerModel *lightModel;
@property (nonatomic, assign) BOOL addNewController;

@property (nonatomic, strong) NSMutableDictionary *lightsDictionary;  //key lightcontroll value
@end

@implementation HomeViewController

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _maskView.backgroundColor = RGBAlphaColor(120, 120, 120, 0.5);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaskAction)];
        tap.numberOfTapsRequired = 1;
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (void)tapMaskAction
{
//    [self.maskView removeFromSuperview];
    self.isCellEdit = NO;
    if (_seletedCellView) {
        [_seletedCellView setOriginalPosition];
    }
}

- (NSMutableArray *)lightControllerArray
{
    if (!_lightControllerArray) {
        _lightControllerArray = [[NSMutableArray alloc] init];
        
#ifdef TEST_CLOSE_BLUETOOTH
        
        NSArray *lightArray = [LightController getAllLightControllersInManagedObjectContext:APPDELEGATE.managedObjectContext];
        
        if (lightArray.count == 0) {
            
            LightControllerModel *blueControllerModel = [[LightControllerModel alloc] init];
            blueControllerModel.name = @"Blue Front Tree Lights";
            blueControllerModel.type = Normal;
            LightController *blueController = [LightController addObjectWithIdentifier:blueControllerModel.name inManagedObjectContext:APPDELEGATE.managedObjectContext];
            [_lightControllerArray addObject:blueController];
            
            LightControllerModel *christmasControllerModel = [[LightControllerModel alloc] init];
            christmasControllerModel.name = @"Christmas Tree-Front Room";
            christmasControllerModel.type = Normal;
            LightController *christmasController = [LightController addObjectWithIdentifier:christmasControllerModel.name inManagedObjectContext:APPDELEGATE.managedObjectContext];
            
            
            [_lightControllerArray addObject:christmasController];
            
        } else {
            
            
//            [_lightControllerArray addObjectsFromArray:lightArray];
        }
        
#endif
    }
    return _lightControllerArray;
}

- (id)init
{
    self = [super init];
    if (self) {
        //
        self.isCellEdit = NO;
        self.isReciveNotify = NO;
        self.addNewController = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    self.useDefaultTableView = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[BluetoothManager sharedInstance] startScanBluetooth];
    
    self.navigationItem.title = @"Paired Controllers";
    self.tableView.allowsSelection = NO;
    
    
    //注册设备查找消息，及超时消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(discoverDeviceAction:) name:Notify_DiscoverDevice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanTimeOutAction:) name:Notify_ScanTimeOut object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectAction:) name:Notify_Disconnect object:nil];
}

- (void)disconnectAction:(NSNotification *)notify
{
//    [MBProgressHUD hideHUD];
    [self checkBluetoothDevice];
}

- (void)discoverDeviceAction:(NSNotification *)notify
{
//    [MBProgressHUD hideHUD];
    
    if (self.isReciveNotify) {
        
        CBPeripheral *periphseral = [[BluetoothManager sharedInstance] getPeripheralWithIdentifier:_lightModel.identifier];
        if (periphseral) {
            self.isReciveNotify = NO;
            
//            [[BluetoothManager sharedInstance] sendData:[LightControllerCommand pairMainControllerCommand] onRespond:^(NSData *data) {
//                //respond
//                [MBProgressHUD hideHUD];
//                
//                Byte value[30] = {0};
//                [data getBytes:&value length:sizeof(value)];
//                
//                if (value[0] == 0xaa && value[1] == 0x0a) {
//                    //success
//                    [self showPairSuccess:periphseral];
//                }
//                else {
//                    //failed
//                    [MBProgressHUD showError:@"Pair Failed."];
//                }
//                
//            } onTimeOut:^{
//                //timeout
//                [MBProgressHUD hideHUD];
//                [MBProgressHUD showError:@"Pair Failed."];
//                
//            }];
            
            [[BluetoothManager sharedInstance] connectPeripheral:periphseral onSuccessBlock:^{
                
                //配对指令
                [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand pairMainControllerCommand:_lightModel.lightID]];
                
                //success
                TipMessageView *tip = [[TipMessageView alloc] init];
                tip.headTitleText = @"Pair Controller";
                tip.tiptilteText = @"Success!";
                tip.tipDetailText = @"Your controller is ready.Please make sure you set up your bulbs,themes and then your schedule.";
                tip.okButtonContent = @"Continue";
                tip.cancelButtonContent = nil;
                
                [tip show];
                //            [self.navigationController pushViewController:tip animated:YES];
                
                //    __weak typeof(tip) temp = tip;
                tip.okActionBlock = ^() {
                    
                    LightController *light = [LightController getObjectWithIdentifier:[periphseral.identifier UUIDString] inManagedObjectContext:APPDELEGATE.managedObjectContext];
                    if (!light) {
                        [MBProgressHUD showError:@"获取对象失败"];
                        return;
                    }
                    
                    //点击事件
                    SettingViewController *settingVC = [[SettingViewController alloc] init];
                    settingVC.headerTitle = _lightModel.name;
                    settingVC.light = light;
                    [self.navigationController pushViewController:settingVC animated:YES];
                };
                
            } onTimeoutBlock:^{
                //timeout
            }];
            
            
        }
    }
    
    //添加设备消息处理
    [self receiveAddNewControllerNotify:notify];
    [self.tableView reloadData];
}

- (void)showPairSuccess:(CBPeripheral *)periphseral
{
    TipMessageView *tip = [[TipMessageView alloc] init];
    tip.headTitleText = @"Pair Controller";
    tip.tiptilteText = @"Success!";
    tip.tipDetailText = @"Your controller is ready.Please make sure you set up your bulbs,themes and then your schedule.";
    tip.okButtonContent = @"Continue";
    tip.cancelButtonContent = nil;
    
    [tip show];
    //            [self.navigationController pushViewController:tip animated:YES];
    
    //    __weak typeof(tip) temp = tip;
    tip.okActionBlock = ^() {
        
        LightController *light = [LightController getObjectWithIdentifier:[periphseral.identifier UUIDString] inManagedObjectContext:APPDELEGATE.managedObjectContext];
        if (!light) {
            [MBProgressHUD showError:@"获取对象失败"];
            return;
        }
        
        //点击事件
        SettingViewController *settingVC = [[SettingViewController alloc] init];
        settingVC.headerTitle = _lightModel.name;
        settingVC.light = light;
        [self.navigationController pushViewController:settingVC animated:YES];
    };
}

- (void)receiveAddNewControllerNotify:(NSNotification *)notify
{
    
    if (self.addNewController) {
        
        [MBProgressHUD hideHUD];
        
        //将扫描到的设备与当前数据库中的设备进行比较，如果有不一样的设备则添加
        CBPeripheral *peripheral = (CBPeripheral *)[notify.userInfo objectForKey:@"CBPeripheral"];
        LightController *light = [LightController getObjectWithIdentifier:[peripheral.identifier UUIDString] inManagedObjectContext:APPDELEGATE.managedObjectContext];
        if (!light) {
            //将设备添加到列表中
            self.addNewController = NO;
            //跳转到found界面
            
            MyLog(@"/n===============  goto FoundViewController 1111 ==================/n ");
            
            FoundViewController *foundVC = [[FoundViewController alloc] init];
            [foundVC loadBackBtn];
            [self.navigationController pushViewController:foundVC animated:YES];
        }
        
    }
}

- (void)showSorryView
{
    TipMessageView *tip = [[TipMessageView alloc] init];
    tip.headTitleText = @"Not Controller Found";
    tip.tiptilteText = @"Sorry,";
    tip.tipDetailText = @"Your selected controller cannot be found. \n Make sure you're within 10ft. of the controller,it's plugged in and try again.";
    tip.okButtonContent = @"Try Again";
    tip.cancelButtonContent = @"Cancel";
    tip.isCancelIcon = YES;
    
    __weak typeof(self) weakSelf = self;
    tip.okActionBlock = ^() {
        //Try again
        if (weakSelf.addNewController)
            [weakSelf addNewController:nil];
        else
            [weakSelf pairController:_lightModel];
    };
    
    [tip show];
}

- (void)scanTimeOutAction:(NSNotification *)notify
{
    [MBProgressHUD hideHUD];
    
    if (self.isReciveNotify  || self.addNewController) {
        
        [self showSorryView];
        
        self.isReciveNotify = NO;
        self.addNewController = NO;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkBluetoothDevice];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)checkBluetoothDevice
{
    [self loadDataFromDataBase];
    
    if (self.lightsDictionary.count == 0) {
        NotFoundViewController *notFoundVC = [[NotFoundViewController alloc] init];
        [self.navigationController pushViewController:notFoundVC animated:NO];
    }
}

- (NSMutableDictionary *)lightsDictionary
{
    if (!_lightsDictionary) {
        _lightsDictionary = [[NSMutableDictionary alloc] init];
    }
    return _lightsDictionary;
}

- (void)loadDataFromDataBase
{
    
    
#ifdef TEST_CLOSE_BLUETOOTH
    
    NSArray *lightArray = [LightController getAllLightControllersInManagedObjectContext:APPDELEGATE.managedObjectContext];
    
    if (lightArray.count == 0) {
        
        LightControllerModel *blueControllerModel = [[LightControllerModel alloc] init];
        blueControllerModel.name = @"Blue Front Tree Lights";
        blueControllerModel.type = Normal;
        LightController *blueController = [LightController addObjectWithIdentifier:blueControllerModel.name inManagedObjectContext:APPDELEGATE.managedObjectContext];
        blueController.name = blueControllerModel.name;
        blueController.deviceName = blueControllerModel.name;
        
        [_lightControllerArray addObject:blueController];
        
        LightControllerModel *christmasControllerModel = [[LightControllerModel alloc] init];
        christmasControllerModel.name = @"Christmas Tree-Front Room";
        christmasControllerModel.type = Normal;
        LightController *christmasController = [LightController addObjectWithIdentifier:christmasControllerModel.name inManagedObjectContext:APPDELEGATE.managedObjectContext];
        christmasController.name = christmasControllerModel.name;
        christmasController.deviceName = christmasControllerModel.name;
        
        [_lightControllerArray addObject:christmasController];
        
    } else {
        
        
        //            [_lightControllerArray addObjectsFromArray:lightArray];
    }
    
#endif
    
    //数据库中没有匹配过的蓝牙设备则跳转到 NotFound
    NSArray *lightControllerArray = [LightController getAllLightControllersInManagedObjectContext:APPDELEGATE.managedObjectContext];
    
    [self.lightsDictionary removeAllObjects];
    for (LightController *lightItem in lightControllerArray) {
        
        if (lightItem.slave) {
            //master
            if ([self.lightsDictionary objectForKey:lightItem.identifier]) {
                NSMutableArray *slavesArray = (NSMutableArray *)[self.lightsDictionary objectForKey:lightItem.identifier];
                if (!slavesArray) {
                    slavesArray = [[NSMutableArray alloc] init];
                }
                [slavesArray addObject:lightItem.slave];
                
            } else{
                NSMutableArray *slavesArray = [[NSMutableArray alloc] init];
                [self.lightsDictionary setObject:slavesArray forKey:lightItem.identifier];
                [slavesArray addObject:lightItem.slave];
            }

        } else if (!lightItem.master && !lightItem.slave) {
            //没有进行绑定的状态
            NSMutableArray *slavesArray = [[NSMutableArray alloc] init];
            [self.lightsDictionary setObject:slavesArray forKey:lightItem.identifier];
        }
    }
    
    self.lightControllerArray = [lightControllerArray copy];
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.lightsDictionary.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section >= self.lightsDictionary.count) {
        return 0;
    }
    
    NSArray *keysArray = [self.lightsDictionary allKeys];
    NSMutableArray *slavesArray = [self.lightsDictionary objectForKey:[keysArray objectAtIndex:section]];
    return slavesArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        return 60;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        return 40;
    }
    
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        if (section >= self.lightsDictionary.count) {
            return 0;
        }
        
        NSArray *keysArray = [self.lightsDictionary allKeys];
        NSMutableArray *slavesArray = [self.lightsDictionary objectForKey:[keysArray objectAtIndex:section]];
        if (slavesArray.count > 0) {
            return 1;
        }
        
        return 0;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
    view.backgroundColor = WhiteColor;
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
    view.backgroundColor = [UIColor clearColor];
    
    if (section >= self.lightsDictionary.count) {
//        view.backgroundColor = WhiteColor;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
        button.backgroundColor = RGBAlphaColor(255, 255, 255, 0.6);
        [button setTitleColor:WhiteColor forState:UIControlStateNormal];
        
        if (section == self.lightsDictionary.count) {
            [button setTitle:@"Add New Controller+" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(addNewController:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button setTitle:@"Create Duplicate/Slave Controller+" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(createDuplicateOrSlaveController:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [view addSubview:button];
    } else {
        
        NSArray *keysArray = [self.lightsDictionary allKeys];
        NSString *identifier = [keysArray objectAtIndex:section];
        LightController *lightController = [LightController getObjectWithIdentifier:identifier inManagedObjectContext:APPDELEGATE.managedObjectContext];
        
        LightControllerCellView *cellView = [[LightControllerCellView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
        
        CBPeripheral *peripheral = [[BluetoothManager sharedInstance] getPeripheralWithIdentifier:lightController.identifier];
        if (peripheral && peripheral.state == CBPeripheralStateConnected) {
            cellView.isConnected = YES;
        } else {
            cellView.isConnected = NO;
        }
        
        if (lightController)
            cellView.lightController = [[LightControllerModel alloc] initWithLightController:lightController];
        
        [view addSubview:cellView];
        
        __weak typeof(cellView) weakCellView = cellView;
        cellView.tapActionBlock = ^(LightControllerModel *light) {
            if (self.isCellEdit) {
                [self tapMaskAction];
                return;
            }
            
            [self pairController:light];
            [self.tableView reloadData];
        };
        
        cellView.deleteActionBlock = ^(LightControllerModel *light) {
            
            //删除事件
            [LightController deleteObject:lightController inManagedObjectContext:APPDELEGATE.managedObjectContext];
            [APPDELEGATE saveContext];
            [self tapMaskAction];
            
            if (weakCellView.isConnected) {
                [[BluetoothManager sharedInstance] disConnectPeripheral];
            }
            
//            [self loadDataFromDataBase];
            [self checkBluetoothDevice];
        };
        
        cellView.showDeleteButtonActionBlock = ^() {
            [self tapMaskAction];
            self.seletedCellView = weakCellView;
            self.isCellEdit = YES;
        };
        
        cellView.hideDeleteButtonActionBlock = ^() {
            self.seletedCellView = nil;
            self.isCellEdit = NO;
        };
    }
    
    // 分隔线
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame)-1, ScreenWidth, 1)];
    line.backgroundColor = WhiteColor;
    [view addSubview:line];
    
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @" ✕ ";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = DefaultCellIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    } else {
        for (UIView *subView in cell.contentView.subviews) {
            [subView removeFromSuperview];
        }
    }
    
    if ([tableView isEqual:self.tableView]) {
     
        LightControllerCellView *view = [[LightControllerCellView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
        
        NSString *identifier = [[self.lightsDictionary allKeys] objectAtIndex:indexPath.section];
        LightController *master = [LightController getObjectWithIdentifier:identifier inManagedObjectContext:APPDELEGATE.managedObjectContext];
        
        CBPeripheral *peripheral = [[BluetoothManager sharedInstance] getPeripheralWithIdentifier:identifier];
        if (peripheral && peripheral.state == CBPeripheralStateConnected) {
            view.isConnected = YES;
        } else {
            view.isConnected = NO;
        }
//        LightController *master = [self.lightControllerArray objectAtIndex:];
//        NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
//        NSArray *sortSetArray = [master.slaves sortedArrayUsingDescriptors:sortDesc];
        
        LightController *slave = master.slave;
        if (slave) {
            LightControllerModel *slaveModel = [[LightControllerModel alloc] init];
            slaveModel.name = slave.name;
            slaveModel.type = Slave;
            view.useDeleteAction = NO;
            view.lightController = slaveModel;
            
//            __weak typeof(view) weakCellView = view;
            view.tapActionBlock = ^(LightControllerModel *light) {
                [self tapMaskAction];
            };
            
            view.arrowClickActionBlock = ^(LightControllerModel *light) {
                if (self.isCellEdit) {
                    [self tapMaskAction];
                    return;
                }
                
                //连接跳转
                [self unLinkSlave:master];
            };
        }
        [cell.contentView addSubview:view];
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//}

// 滑动删除
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //删除时设备需要先断开连接
//    }
//}

// 去掉headview的粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 60;
    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0)
    {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y >= sectionHeaderHeight)
    {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

#pragma mark -ButtonEvent
- (void)addNewController:(UIButton *)button
{
    [MBProgressHUD showMessage:nil];
    
    if (self.isCellEdit) {
        [self tapMaskAction];
        return;
    }
    
    [self startScanBluetooth];
    self.addNewController = YES;
}

- (void)createDuplicateOrSlaveController:(UIButton *)button
{
    if (self.isCellEdit) {
        [self tapMaskAction];
        return;
    }
    
    DuplicateControllerViewController *duplicate = [[DuplicateControllerViewController alloc] init];
    duplicate.controllerArray = self.lightControllerArray;
    [self.navigationController pushViewController:duplicate animated:YES];
}

- (void)pairController:(LightControllerModel *)ligntController
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showMessage:nil];
    });
    
    _lightModel = ligntController;
    __block LightController *light = [LightController getObjectWithIdentifier:ligntController.identifier inManagedObjectContext:APPDELEGATE.managedObjectContext];
    if (!light) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"获取对象失败"];
        });
        return;
    }
    
#ifdef TEST_CLOSE_BLUETOOTH
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    settingVC.headerTitle = ligntController.name;
    settingVC.light = light;
    [self.navigationController pushViewController:settingVC animated:YES];
#else
    //调用蓝牙接口连接测试
    __block CBPeripheral *peripheral = [[BluetoothManager sharedInstance] getPeripheralWithIdentifier:light.identifier];
    
    if (![peripheral isEqual:[BluetoothManager sharedInstance].peripheral]
        || peripheral.state != CBPeripheralStateConnected) {
        
        __weak typeof(self) weakSelf = self;
        [[BluetoothManager sharedInstance] disConnectPeripheral:^{
            
//            if (![peripheral isEqual:[BluetoothManager sharedInstance].peripheral]) {
//                [BluetoothManager sharedInstance].peripheral = peripheral;
//            }
            
            if (!peripheral) {
                [weakSelf startScanBluetooth];
                weakSelf.isReciveNotify = YES;
                
            } else {
                [[BluetoothManager sharedInstance] connectPeripheral:peripheral onSuccessBlock:^{
                    
                    MyLog(@"\n==lightController:%@==\n", light);
                    
                    //配对指令
                    [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand pairMainControllerCommand:_lightModel.lightID]];
                    
                    //success
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUD];
                    });
                    
                    SettingViewController *settingVC = [[SettingViewController alloc] init];
                    settingVC.headerTitle = _lightModel.name;
                    settingVC.light = light;
                    [self.navigationController pushViewController:settingVC animated:YES];
                    
                } onTimeoutBlock:^{
                    //timeout
                    
                    [MBProgressHUD hideHUD];
                    [self showSorryView];
                }];
            }
        }];
        
    }
    else {
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
        
        SettingViewController *settingVC = [[SettingViewController alloc] init];
        settingVC.headerTitle = _lightModel.name;
        settingVC.light = light;
        [self.navigationController pushViewController:settingVC animated:YES];
    }    
   
#endif
    
}

//- (void)connectPeripheral
//{
//    
//}

#pragma mark Slave Unlink 事件
- (void)unLinkSlave:(LightController *)master
{
    //
    SlaveControllerViewController *slaveVC = [[SlaveControllerViewController alloc] init];
    slaveVC.light = master;
    [self.navigationController pushViewController:slaveVC animated:YES];
    
}

@end
