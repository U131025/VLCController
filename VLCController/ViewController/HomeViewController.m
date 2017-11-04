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
#import "SetupResultViewController.h"
#import "WkWebViewController.h"
#import "UIViewController+Visible.h"
#import "ScanViewController.h"
#import "PaireControllerViewController.h"

@interface HomeViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *lightControllerArray; // of LightControllerModel
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) LightControllerCellView *seletedCellView;
@property (nonatomic, assign) BOOL isCellEdit;

@property (nonatomic, assign) BOOL isReciveNotify;
@property (nonatomic, strong) LightControllerModel *lightModel;
@property (nonatomic, assign) BOOL addNewController;

@property (nonatomic, strong) NSMutableDictionary *lightsDictionary;  //key lightcontroll value
@property (nonatomic, strong) UIView *headerLineView;
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
            blueControllerModel.name = @"Tv221u_qwe";
            blueControllerModel.macAddress = @"Tv221u_qwe";
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
        self.isBackButton = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    self.useDefaultTableView = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Paired Controllers";
    self.tableView.allowsSelection = NO;
    self.tableView.tableHeaderView = [self createHeaderView];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadDataFromDataBase];
    }];
    
    self.backgroundImageView.image = [UIImage imageNamed:@"pairBackground"];
    
    //注册设备查找消息，及超时消息
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(discoverDeviceAction:) name:Notify_DiscoverDevice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanTimeOutAction:) name:Notify_ScanTimeOut object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectAction:) name:Notify_Disconnect object:nil];
    
    [[BluetoothManager sharedInstance] setBlockForDisconnected:^(CBPeripheral *peripheral) {

        UIViewController *viewController = [UIViewController visibleViewController];
        if (viewController
            && ![viewController isKindOfClass:[HomeViewController class]]
            && ![viewController isKindOfClass:[ScanViewController class]]
            && ![viewController isKindOfClass:[PaireControllerViewController class]]) {

            [viewController.navigationController popToViewController:self animated:YES];
        }
    }];
}

- (UIView *)createHeaderView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 150)];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pair header"]];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(view);
        make.height.mas_equalTo(100);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor whiteColor];
    [view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(view);
        make.height.mas_equalTo(1);
    }];
    self.headerLineView = line;
    self.headerLineView.hidden = self.lightControllerArray.count > 0 ? NO : YES;
    
    return view;
}

- (void)disconnectAction:(NSNotification *)notify
{
    [self checkBluetoothDevice];
}

- (void)discoverDeviceAction:(NSNotification *)notify
{
    if (self.isReciveNotify) {
        
        CBPeripheral *periphseral = [[BluetoothManager sharedInstance] peripheral];
        if (periphseral) {
            self.isReciveNotify = NO;
            
            LightController *light = [LightController getObjectWithIdentifier:_lightModel.identifier inManagedObjectContext:APPDELEGATE.managedObjectContext];
            
            //弹出配对密码输入框
            if (light.password) {
                [self connectPeripheralWithLightController:light password:light.password];
//                [self pairControllerWithPassword:light.password peripheral:periphseral light:light];
            }
            else {
                //没有记录则弹窗
                [self showInputView:^(NSString *password) {
                    //
                    [self connectPeripheralWithLightController:light password:password];
//                    [self pairControllerWithPassword:password peripheral:periphseral light:light];
                    
                } cancel:^{
                    nil;
                }];
            }

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
            [MBProgressHUD showError:@"获取对象失败" toView:self.view];
            return;
        }
        
        //点击事件
        SettingViewController *settingVC = [[SettingViewController alloc] initWithPeripheral:periphseral];
        settingVC.headerTitle = _lightModel.name;
        settingVC.light = light;
        [self.navigationController pushViewController:settingVC animated:YES];
    };
}

- (void)receiveAddNewControllerNotify:(NSNotification *)notify
{
    
    if (self.addNewController) {
        
        [self hideHUD];
        
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
    [self hideHUD];
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    [self hideHUD];
    [super viewWillDisappear:animated];
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
        blueControllerModel.name = @"Tv221u_qwe";
        blueControllerModel.macAddress = @"Tv221u_qwe12345";
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
        
        [APPDELEGATE saveContext];
        
    } else {
        
        
        //            [_lightControllerArray addObjectsFromArray:lightArray];
    }
    
#endif
    
//    [[BluetoothManager sharedInstance] startScanBluetooth];
    
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
    if ([self.tableView.mj_header isRefreshing]) {
        [self.tableView.mj_header endRefreshing];
    }
    
    self.lightControllerArray = [lightControllerArray copy];
    [self.tableView reloadData];
    
    if (self.headerLineView) {
        self.headerLineView.hidden = self.lightControllerArray.count > 0 ? NO : YES;
    }
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
        
        if (section >= self.lightsDictionary.count)
            return 150;
        
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
        
        view.frame = CGRectMake(0, 0, ScreenWidth, 150);
        
        UIButton *button = [[UIButton alloc] init];
//        button.backgroundColor = RGBAlphaColor(255, 255, 255, 0.6);
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 1;
        button.titleLabel.font = Font(16);
        [button setTitleColor:WhiteColor forState:UIControlStateNormal];
        
        if (section == self.lightsDictionary.count) {
            [button setTitle:@"Add New Controller" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(addNewController:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button setTitle:@"Create Duplicate/Slave Controller+" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(createDuplicateOrSlaveController:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(50);
            make.right.equalTo(view).offset(-50);
            make.center.equalTo(view);
            make.height.mas_equalTo(50);
        }];
        
        UIButton *websiteButton = [[UIButton alloc] init];
        websiteButton.titleLabel.font = Font(16);
        [websiteButton setTitle:@"View Tutorials" forState:UIControlStateNormal];
        [websiteButton addTarget:self action:@selector(viewTutorials) forControlEvents:UIControlEventTouchUpInside];
        [websiteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [view addSubview:websiteButton];
        [websiteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(button.mas_bottom).offset(10);
            make.left.right.equalTo(button);
            make.height.mas_equalTo(30);
        }];
        
        
    } else {
        
        NSArray *keysArray = [self.lightsDictionary allKeys];
        NSString *identifier = [keysArray objectAtIndex:section];
        LightController *lightController = [LightController getObjectWithIdentifier:identifier inManagedObjectContext:APPDELEGATE.managedObjectContext];
        
        LightControllerCellView *cellView = [[LightControllerCellView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
        
        CBPeripheral *peripheral = [[BluetoothManager sharedInstance] peripheral];
        if ([identifier isEqualToString:[peripheral.identifier UUIDString]]
             && peripheral
             && peripheral.state == CBPeripheralStateConnected) {
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
            
            [[BluetoothManager sharedInstance] disconnectAllPeripheral];
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
        
        // 分隔线
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame)-1, ScreenWidth, 1)];
        line.backgroundColor = WhiteColor;
        [view addSubview:line];
    }
    
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
        
        CBPeripheral *peripheral = [[BluetoothManager sharedInstance] peripheral];
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
    if (self.isCellEdit) {
        [self tapMaskAction];
        return;
    }
    
    NotFoundViewController *notFoundVC = [[NotFoundViewController alloc] initWithBackButton];
    [self.navigationController pushViewController:notFoundVC animated:YES];
    
    
//    [self startScanBluetooth];
//    self.addNewController = YES;
}

- (void)viewTutorials
{
//#warning 跳转到website
    WkWebViewController *webView = [[WkWebViewController alloc] initWithWebViewUrl:HomePageUrl titleName:@"Tutorials"];
    [self.navigationController pushViewController:webView animated:YES];
    
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
    
    _lightModel = ligntController;
    __block LightController *light = [LightController getObjectWithIdentifier:ligntController.identifier inManagedObjectContext:APPDELEGATE.managedObjectContext];
    if (!light) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:@"获取对象失败" toView:self.view];
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
    __block CBPeripheral *peripheral = [[BluetoothManager sharedInstance] peripheral];
    
    if (![peripheral.name isEqualToString:light.macAddress]
        || peripheral.state != CBPeripheralStateConnected) {
        
        [MBProgressHUD showMessage:@"" toView:self.view];
        
//        __weak typeof(self) weakSelf = self;
        if (peripheral.state == CBPeripheralStateConnected
            && [peripheral.name isEqualToString:light.macAddress]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view];
            });
            
            SettingViewController *settingVC = [[SettingViewController alloc] initWithPeripheral:peripheral];
            settingVC.headerTitle = _lightModel.name;
            settingVC.light = light;
            [self.navigationController pushViewController:settingVC animated:YES];
            return;
        }
        
        [[BluetoothManager sharedInstance] disconnectAllPeripheral];
        
        //弹出配对密码输入框
        if (light.password) {
            [self connectPeripheralWithLightController:light password:light.password];
            //                [self pairControllerWithPassword:light.password peripheral:peripheral light:light];
        }
        else {
            [self hideHUD];
            
            //没有记录则弹窗
            [self showInputView:^(NSString *password) {
                //
                [self connectPeripheralWithLightController:light password:password];
                //                    [self pairControllerWithPassword:password peripheral:peripheral light:light];
                
            } cancel:^{
                nil;
            }];
        }
        
    }
    else {
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
        });
        
        SettingViewController *settingVC = [[SettingViewController alloc] initWithPeripheral:peripheral];
        settingVC.headerTitle = _lightModel.name;
        settingVC.light = light;
        [self.navigationController pushViewController:settingVC animated:YES];
    }    
   
#endif
    
}

- (void)connectPeripheralWithLightController:(LightController *)light password:(NSString *)password
{    
    [[BluetoothManager sharedInstance] connectWithName:light.macAddress oldPassword:password newPassword:password successBlock:^(CBPeripheral *peripheral, id data, BLERespondType type) {
        
        [self hideHUD];
        
        SettingViewController *settingVC = [[SettingViewController alloc] initWithPeripheral:peripheral];
        settingVC.headerTitle = _lightModel.name;
        settingVC.light = light;
        [self.navigationController pushViewController:settingVC animated:YES];
        
    } faileBlock:^(CBPeripheral *peripheral, id data, BLERespondType type) {
        
        [self hideHUD];
        
        if ([data isKindOfClass:[NSString class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:data toView:self.view];
            });
        }
        
        //失败
        SetupResultType resultType = SetupResultTypeOops;
        SetupResultViewController *resultVC = [[SetupResultViewController alloc] initWithType:resultType];
        
        [self.navigationController pushViewController:resultVC animated:YES];
    }];
    
//    [[BluetoothManager sharedInstance] connectPeriperalWithIndex:0 deviceName:light.macAddress oldPassword:password newPassword:password successBlock:^(CBPeripheral *peripheral, NSData *data, BLERespondType type) {
//        
//        
//    } faileBlock:^(CBPeripheral *peripheral, id data, BLERespondType type) {
//        
//    }];
    
}

- (void)hideHUD
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view];
    });
}

- (void)pairControllerWithPassword:(NSString *)password peripheral:(CBPeripheral *)peripheral light:(LightController *)light
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        [MBProgressHUD showMessage:nil toView:self.view];
    });
    
    [[BluetoothManager sharedInstance] connectWithName:peripheral.name oldPassword:password newPassword:password successBlock:^(CBPeripheral *peripheral, id data, BLERespondType type) {
        
        [[BluetoothManager sharedInstance] sendData:[LightControllerCommand pairMainControllerCommand:_lightModel.lightID] onRespond:nil onTimeOut:nil];
        
        //success
        [self hideHUD];
        
        SettingViewController *settingVC = [[SettingViewController alloc] initWithPeripheral:peripheral];
        settingVC.headerTitle = _lightModel.name;
        settingVC.light = light;
        [self.navigationController pushViewController:settingVC animated:YES];
    } faileBlock:^(CBPeripheral *peripheral, id data, BLERespondType type) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
            [self showSorryView];
        });
        
    }];
    
//    [[BluetoothManager sharedInstance] pairDeviceWithOldPassword:password newPassWord:password withResponds:^(NSData *data) {
//        //
//        const char *pData = [data bytes];
//        
//        if (pData[0] == 0) {
//            //success
//            NSLog(@"\n ==== 配对成功 ===== \n");
//            
//            //success
//            if (peripheral.state == CBPeripheralStateConnected) {
//                
//                MyLog(@"\n==lightController:%@==\n", light);
//                
//                //配对指令
//                [[BluetoothManager sharedInstance] sendData:[LightControllerCommand pairMainControllerCommand:_lightModel.lightID] onRespond:nil onTimeOut:nil];
//                
////                [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand pairMainControllerCommand:_lightModel.lightID]];
//                
//                //success
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [MBProgressHUD hideHUD];
//                });
//                
//                SettingViewController *settingVC = [[SettingViewController alloc] initWithPeripheral:peripheral];
//                settingVC.headerTitle = _lightModel.name;
//                settingVC.light = light;
//                [self.navigationController pushViewController:settingVC animated:YES];
//            }
//        }
//        else if (pData[0] == 1) {
//            //password error
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD hideHUD];
//                [MBProgressHUD showError:@"Invalid password"];
//            });
//            
//        }
//        else if (pData[0] == 2) {
//            //modify success
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD hideHUD];
//            });
//        }
//        else if (pData[0] == 3) {
//            //cancel password
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD hideHUD];
//            });
//        }
//        
//    }];
//    
//    [[BluetoothManager sharedInstance] connectPeripheral:peripheral onSuccessBlock:^{
//        //success
//        
//    } onTimeoutBlock:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD hideHUD];
//            [self showSorryView];
//        });
//    }];
    
}

#pragma mark Slave Unlink 事件
- (void)unLinkSlave:(LightController *)master
{
    //
    SlaveControllerViewController *slaveVC = [[SlaveControllerViewController alloc] init];
    slaveVC.light = master;
    [self.navigationController pushViewController:slaveVC animated:YES];
    
}

@end
