//
//  SettingViewController.m
//  VLCController
//
//  Created by mojingyu on 16/1/15.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "SettingViewController.h"
#import "MyComBoxView.h"
#import "NSString+Extension.h"
#import "ScheduleOptionViewController.h"
#import "ManageBulbsViewController.h"
#import "ManageThemeViewController.h"
#import "DropDownListView.h"
#import "Theme+Fetch.h"
#import "Channel+Fetch.h"
#import "BluetoothManager.h"
#import "ThemeModel.h"
#import "ZJSwitch.h"
#import "ManageWirelessPlugsViewController.h"
#import "Schedule+Fetch.h"
#import "ScheduleItem+Fetch.h"
#import "ScheduleModel.h"
#import "NSString+Extension.h"
#import "UIColor+extension.h"

#define Notify_ChangeTheme @"ChangeTheme"

@interface SettingViewController ()<UITableViewDataSource, UITableViewDelegate, DropdownListViewDelegate>

@property (nonatomic, strong) MyComBoxView *themeComboxView;
@property (nonatomic, strong) DropdownListView *themeDropdownListView;
@property (nonatomic, strong) Theme *selectedTheme; //选中的主题

@property (nonatomic, copy) NSArray *defualtThemesArray;   //缺省的主题

@property (nonatomic, assign) BOOL useSchedulePlan;

@property (nonatomic, strong) NSMutableArray *selThemeChannelArray;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation SettingViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.useSchedulePlan = NO;
    }
    return self;
}

- (NSArray *)defualtThemesArray
{
    if (!_defualtThemesArray) {
        _defualtThemesArray = @[@{@"name":@"All Red", @"color":[UIColor redColor], @"warm":@"0x00"},
                                @{@"name":@"All Green", @"color":[UIColor greenColor], @"warm":@"0x00"},
                                @{@"name":@"All Warm Clear", @"color":RGBFromColor(0x000000), @"warm":@"0xff"},
                                @{@"name":@"All Winter White", @"color":RGBFromColor(0xFFFFFF), @"warm":@"0x00"}];
    }
    return _defualtThemesArray;
}

- (void)setHeaderTitle:(NSString *)headerTitle
{
    _headerTitle = headerTitle;
    self.navigationItem.title = headerTitle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.light.themeName) {
        self.selectedTheme = [Theme getThemeWithWithName:self.light.themeName withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
        if (!self.selectedTheme) {
            self.light.themeName = nil;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeThemeNotify:) name:Notify_ChangeTheme object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectAction:) name:Notify_Disconnect object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.useSchedulePlan = [self.light.useLightSchedule boolValue];
    self.themeComboxView.enable = !self.useSchedulePlan;
    
    //检查主题，如果没有在数据库中存在则置空
//    NSLog(@"== themeName: %@ ==", self.light.themeName);
//    if (self.light.themeName) {
//        Theme *itemTheme = [Theme getThemeWithWithName:_themeComboxView.contentText withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
//        if (!itemTheme) {
//            _themeComboxView.contentText = @"";
//        }
//    }
    
    if (self.light.themeName) {
        self.selectedTheme = [Theme getThemeWithWithName:self.light.themeName withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
        if (!self.selectedTheme) {
            self.light.themeName = nil;
            _themeComboxView.contentText = @"";
        }
        else {
            _themeComboxView.contentText = self.light.themeName;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)selThemeChannelArray
{
    if (!_selThemeChannelArray) {
        _selThemeChannelArray = [[NSMutableArray alloc] init];
    }
    return _selThemeChannelArray;
}

- (void)loadBackBtn
{
    [super loadBackBtn];
}

- (void)btnBackClicked:(UIButton *)sender
{
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[HomeViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

- (void)disconnectAction:(NSNotification *)notify
{
    if (_hud) {
        [_hud hide:YES];
        _hud = nil;
    }
    
    [MBProgressHUD showError:@"Bluetooth device has been disconneted."];
}

#pragma mark - Getter
- (MBProgressHUD *)hud
{
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.mode = MBProgressHUDModeAnnularDeterminate;
    }
    return _hud;
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 4) {
        return 4;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 3) {
        return 100;
    } else if (section != 4) {
        return 60;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
    view.backgroundColor = [UIColor clearColor];
    
    if (section == 3) {
        view.frame = (CGRect){0,0,ScreenWidth,100};
        UIButton *updateButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 20, ScreenWidth-80, 60)];
        updateButton.layer.borderColor = WhiteColor.CGColor;
        updateButton.layer.borderWidth = 1;
        [updateButton setTitle:@"Update Controller" forState:UIControlStateNormal];
        [updateButton setTitleColor:WhiteColor forState:UIControlStateNormal];
        [updateButton addTarget:self action:@selector(updateControllerButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:updateButton];
        
    } else {
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 200, 60)];
        titleLabel.textColor = WhiteColor;
        titleLabel.font = Font(16);
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [view addSubview:titleLabel];
        
        if (section == 0) {
            titleLabel.text = @"Turn Power On/Off";
            
            ZJSwitch *powerSwitch = [[ZJSwitch alloc] initWithFrame:CGRectMake(ScreenWidth-80, 15, 60, 30)];
            powerSwitch.on = [self.light.isPowerOn boolValue];
            powerSwitch.backgroundColor = [UIColor clearColor];
            powerSwitch.onText = @"ON";
            powerSwitch.offText = @"OFF";
            powerSwitch.borderColor = WhiteColor;
            powerSwitch.lazy = YES;
            
            if (powerSwitch.isOn)
                powerSwitch.thumbTintColor = RGBAlphaColor(68, 167, 215, 1);
            else
                powerSwitch.thumbTintColor = WhiteColor;
            
            powerSwitch.offThumbTiniColor = WhiteColor;
            powerSwitch.offTextColor = WhiteColor;
            powerSwitch.tintColor = RGBAlphaColor(41, 118, 154, 1);
            
            powerSwitch.onThumbTiniColor = RGBAlphaColor(68, 167, 215, 1);
            powerSwitch.onTextColor = RGBAlphaColor(68, 167, 215, 1);
            powerSwitch.onTintColor = WhiteColor;
            
//            [powerSwitch addTarget:self action:@selector(powerSwitchAction:) forControlEvents:UIControlEventValueChanged];
            
            [powerSwitch addTarget:self action:@selector(powerSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:powerSwitch];
            
        } else if (section == 1) {
            
            NSString *titleText = @"Set Color/Theme";
            titleLabel.text = titleText;
            //主题下拉菜单
            __weak typeof(self) weakSelf = self;
            
            CGSize textSize = [titleText sizeWithFont:Font(16) maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
            CGFloat offsetX = CGRectGetMinX(titleLabel.frame)+textSize.width+20;
            CGFloat comboxWidth = ScreenWidth - offsetX - 20;
            _themeComboxView = [[MyComBoxView alloc] initWithFrame:CGRectMake(offsetX, 15, comboxWidth, 30)];
            
            if (self.light.themeName) {
                _themeComboxView.contentText = self.light.themeName;
            }
            NSLog(@"=== themeName:%@ ====", self.light.themeName);
            _themeComboxView.clickActionBlock = ^(BOOL isExpand) {
                [weakSelf showTheme];
            };
            [view addSubview:_themeComboxView];
            
            self.themeComboxView.enable = !self.useSchedulePlan;
            
        } else if (section == 2) {
            titleLabel.text = @"Set light Schedule";
            ZJSwitch *scheduleSwitch = [[ZJSwitch alloc] initWithFrame:CGRectMake(ScreenWidth-80, 14, 60, 30)];
            scheduleSwitch.on = self.useSchedulePlan;
            scheduleSwitch.borderColor = WhiteColor;
            scheduleSwitch.backgroundColor = [UIColor clearColor];
            
            scheduleSwitch.onText = @"ON";
            scheduleSwitch.offText = @"OFF";
            
            if (scheduleSwitch.isOn)
                scheduleSwitch.thumbTintColor = RGBAlphaColor(68, 167, 215, 1);
            else
                scheduleSwitch.thumbTintColor = WhiteColor;
            
            scheduleSwitch.offThumbTiniColor = WhiteColor;
            scheduleSwitch.offTextColor = WhiteColor;
            scheduleSwitch.tintColor = RGBAlphaColor(41, 118, 154, 1);
            
            scheduleSwitch.onThumbTiniColor = RGBAlphaColor(68, 167, 215, 1);
            scheduleSwitch.onTextColor = RGBAlphaColor(68, 167, 215, 1);
            scheduleSwitch.onTintColor = WhiteColor;
            
            [scheduleSwitch addTarget:self action:@selector(scheduleSwitchAction:) forControlEvents:UIControlEventValueChanged];
            [view addSubview:scheduleSwitch];
        }
        
    }
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView.tintColor = WhiteColor;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
    
    UILabel *lineLabel = [[UILabel alloc] init];
    lineLabel.backgroundColor = WhiteColor;
    lineLabel.frame = (CGRect){0, 0, ScreenWidth, 1};
    [view addSubview:lineLabel];
    
    UILabel *titleLLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 200, 50)];
    [view addSubview:titleLLabel];
    titleLLabel.textAlignment = NSTextAlignmentLeft;
    titleLLabel.font = Font(16);
    titleLLabel.textColor = WhiteColor;
    
    if (indexPath.row == 0) {
        
        titleLLabel.text = @"Edit Schedule";
        CGSize titleSize = [titleLLabel.text sizeWithFont:Font(16) maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(titleLLabel.frame)+titleSize.width+5, 5, 200, CGRectGetHeight(titleLLabel.frame))];
//        subTitle.text = @"M\tT\tW\tTh\tF\tSa\tSu";
        subTitle.textColor = WhiteColor;
        subTitle.textAlignment = NSTextAlignmentCenter;
        subTitle.font = Font(12);
        [view addSubview:subTitle];
        
    } else if (indexPath.row == 1) {
        titleLLabel.text = @"Manage Bulbs";
    } else if (indexPath.row == 2) {
        titleLLabel.text = @"Manage Themes/Colors";
    } else if (indexPath.row == 3) {
        titleLLabel.text = @"Manage Wireless Plug";
        
        UILabel *lineBottomLabel = [[UILabel alloc] init];
        lineBottomLabel.backgroundColor = WhiteColor;
        lineBottomLabel.frame = (CGRect){0, CGRectGetMaxY(view.frame)-1, ScreenWidth, 1};
        [view addSubview:lineBottomLabel];
    }
    
    //arrow
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth- 40, 10, 20, 40)];
    arrowImageView.image = [UIImage imageNamed:@"arrow"];
    [cell.contentView addSubview:arrowImageView];
    
    cell.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:view];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        //Edit Schedule
        ScheduleOptionViewController *scheduleVC = [[ScheduleOptionViewController alloc] init];
        scheduleVC.light = self.light;
        [self.navigationController pushViewController:scheduleVC animated:YES];
    } else if (indexPath.row == 1) {
        
        //需要判断蓝牙状态
        if ([[BluetoothManager sharedInstance] isConnectedPeripheral]) {
            //Manage Blues
            ManageBulbsViewController *bulbsVC = [[ManageBulbsViewController alloc] init];
            bulbsVC.light = self.light;
            [self.navigationController pushViewController:bulbsVC animated:YES];
        }
        else {
            [MBProgressHUD showError:@"Bluetooth device has been disconnected."];
        }
        
    } else if (indexPath.row == 2) {
        //Manage Themes
        ManageThemeViewController *themeVC = [[ManageThemeViewController alloc] init];
        themeVC.light = self.light;
        [self.navigationController pushViewController:themeVC animated:YES];
        
    } else if (indexPath.row == 3) {
        
        if (![[BluetoothManager sharedInstance] isConnectedPeripheral]) {
            [MBProgressHUD showError:@"Bluetooth device has been disconnected."];
            return;
        }
        
        //Manage Wireless Plug
        ManageWirelessPlugsViewController *wirelessVC = [[ManageWirelessPlugsViewController alloc] init];
        wirelessVC.light = self.light;
        [self.navigationController pushViewController:wirelessVC animated:YES];
    }
}

#pragma mark Action
- (void)updateControllerButtonClick
{
    if (![[BluetoothManager sharedInstance] isConnectedPeripheral]) {
        [MBProgressHUD showError:@"Bluetooth device has been disconnected."];
        return;
    }
    
    [self updateControllerAction];
    
}

- (void)updateControllerAction
{
//    [MBProgressHUD showMessage:nil];
    
    //使用计划
    if (self.useSchedulePlan) {
        
        //发送edit schedule自定义计划任务
        if (![self.light.isCustomSchedule boolValue]) {
            //simple plan
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self setSimpleSchedulePlan];
            });
            
            
        } else {
            //custom plan
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self setCustomSchedulePlan];
            });
        }
        
//        [MBProgressHUD hideHUD];
        
    } else {
        // 先发送 选中的主题模式对应通道颜色配置
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self changeThemeAction:self.selectedTheme];
        });
    }
    
}

- (NSString *)getByteTimeWithDateString:(NSString *)dateStr withInFormat:(NSString *)dateFormat withOutFormat:(NSString *)outFormatString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    
    NSDate *dateData = [dateFormatter dateFromString:dateStr];
    
    NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
    [outFormat setDateFormat:outFormatString];
    NSString *outTimeStr = [outFormat stringFromDate:dateData];
    return outTimeStr;
}

- (NSString *)getByteTimeWithDateString:(NSString *)dateStr withFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    
    NSDate *dateData = [dateFormatter dateFromString:dateStr];
    
    NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
    [outFormat setDateFormat:@"HHmm"];
    NSString *outTimeStr = [outFormat stringFromDate:dateData];
    return outTimeStr;
    
//    NSString *hightValue = [outTimeStr substringToIndex:2];
//    NSString *lowValue = [outTimeStr substringFromIndex:2];
//    
//    Byte timeBytes[2] = {0};
//    timeBytes[0] = [hightValue hexStringConvertIntValue];
//    timeBytes[1] = [lowValue hexStringConvertIntValue];
//    
//    return timeBytes;
    
//    NSData *timeData = [outTimeStr dataUsingEncoding:NSUTF8StringEncoding];
//    return (Byte *)[timeData bytes];
}

- (void)setSimpleSchedulePlan
{
    //计划
    Schedule *simpleSchedule = [Schedule getWithWithName:SimpleSchedule withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
    
    NSArray *items = [ScheduleItem fetchWithSchedule:simpleSchedule inManageObjectContext:APPDELEGATE.managedObjectContext];
    
    if (items == 0) {
        return;
    }
    
    float progress = 0.0f;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hud.labelText = @"Updating Controller...";
    });
    
    NSInteger dayIndex = 1;
    NSInteger chanenlIndex = 0;
    for (ScheduleItem *item in items) {
        ScheduleItemModel *itemModel = [[ScheduleItemModel alloc] initWithScheduleItem:item];
        if (!itemModel.isSelected) {
            progress = ((float)(dayIndex) / (float)items.count);
            dispatch_async(dispatch_get_main_queue(), ^{
                // Instead we could have also passed a reference to the HUD
                // to the HUD to myProgressTask as a method parameter.
                [MBProgressHUD HUDForView:self.navigationController.view].progress = progress;
            });
            dayIndex++;
            continue;
        }
        
        //获取主题
        Theme *itemTheme = [Theme getThemeWithWithName:itemModel.themeName withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
        
        //通道
        NSArray *channelArray = [Channel getChannelWithTheme:itemTheme inManageObjectContext:APPDELEGATE.managedObjectContext];
        
        chanenlIndex = 1;
        for (Channel *channel in channelArray) {
            
            NSString *timeOnBtye = [self getByteTimeWithDateString:simpleSchedule.timeOn withFormat:ScheduleTimeFormat];
            NSString *timeOffBtye = [self getByteTimeWithDateString:simpleSchedule.timeOff withFormat:ScheduleTimeFormat];
            
            [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand updateController:YES withDayIndex:dayIndex withChannel:[[ChannelModel alloc] initWithChannel:channel] withOnTime:timeOnBtye withOffTime:timeOffBtye isPhotoCell:[simpleSchedule.isPhotoCell boolValue]] withIdentifier:self.light.identifier];
            
            progress = (1.0f / (float)items.count) * ((float)chanenlIndex / (float)channelArray.count);
            progress += ((float)(dayIndex-1) / (float)items.count);
            dispatch_async(dispatch_get_main_queue(), ^{
                // Instead we could have also passed a reference to the HUD
                // to the HUD to myProgressTask as a method parameter.
                [MBProgressHUD HUDForView:self.navigationController.view].progress = progress;
            });
            chanenlIndex++;
            
            [NSThread sleepForTimeInterval:0.5];
        }
        
        dayIndex++;
    }
    
    //结束
    [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand compeleteCommandOnUseSchedulePlan:YES] withIdentifier:self.light.identifier];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hud hide:YES];
        _hud =nil;        
//        [MBProgressHUD showSuccess:@"Complete"];

    });
    
}

- (void)setCustomSchedulePlan
{
    //计划
    Schedule *customSchedule = [Schedule getWithWithName:CustomSchedule withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
    
    MyLog(@"\n=============\n timeOn: %@ \ntimeOff:%@  \n============\n", customSchedule.timeOn, customSchedule.timeOff);
    
    NSArray *items = [ScheduleItem fetchWithSchedule:customSchedule inManageObjectContext:APPDELEGATE.managedObjectContext];
    
    if (items == 0) {
//        [MBProgressHUD showError:@"Please edit simple schedule."];
        return;
    }
    
    float progress = 0.0f;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hud.labelText = @"Updating Controller...";
    });
    
    NSInteger dayIndex = 1;
    NSInteger chanenlIndex = 0;
    for (ScheduleItem *item in items) {
        
        ScheduleItemModel *itemModel = [[ScheduleItemModel alloc] initWithScheduleItem:item];
        if (!itemModel.isSelected) {
            progress = ((float)(dayIndex) / (float)items.count);
            dispatch_async(dispatch_get_main_queue(), ^{
                // Instead we could have also passed a reference to the HUD
                // to the HUD to myProgressTask as a method parameter.
                [MBProgressHUD HUDForView:self.navigationController.view].progress = progress;
            });
            
            dayIndex++;
            continue;
        }
        
        //获取主题
        Theme *itemTheme = [Theme getThemeWithWithName:itemModel.themeName withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
        
        //通道
        NSArray *channelArray = [Channel getChannelWithTheme:itemTheme inManageObjectContext:APPDELEGATE.managedObjectContext];
        
        chanenlIndex = 1;
        for (Channel *channel in channelArray) {
            
            NSString *timeOnBtye = [self getByteTimeWithDateString:customSchedule.timeOn withFormat:ScheduleTimeFormat];
            NSString *timeOffBtye = [self getByteTimeWithDateString:customSchedule.timeOff withFormat:ScheduleTimeFormat];
            
            [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand updateController:NO withDayIndex:dayIndex withChannel:[[ChannelModel alloc] initWithChannel:channel] withOnTime:timeOnBtye withOffTime:timeOffBtye isPhotoCell:[customSchedule.isPhotoCell boolValue]] withIdentifier:self.light.identifier];
            
            progress = (1.0f/ (float)items.count) * ( (float)chanenlIndex / (float)channelArray.count);
            progress += ((float)(dayIndex-1) / (float)items.count);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Instead we could have also passed a reference to the HUD
                // to the HUD to myProgressTask as a method parameter.
                [MBProgressHUD HUDForView:self.navigationController.view].progress = progress;
            });
            chanenlIndex++;
            
            if ([channel.index integerValue] == 1)
                [NSThread sleepForTimeInterval:0.6];
            else
                [NSThread sleepForTimeInterval:0.05];
        }
        
        
        dayIndex++;
    }
    
    //结束
    [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand compeleteCommandOnUseSchedulePlan:YES] withIdentifier:self.light.identifier];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hud hide:YES];
        _hud =nil;
//        [MBProgressHUD showSuccess:@"Complete"];
        
    });
}

- (void)scheduleSwitchAction:(UISwitch *)scheduleSwitch
{
    self.useSchedulePlan = scheduleSwitch.isOn;
    self.themeComboxView.enable = !scheduleSwitch.isOn;
    
    self.light.useLightSchedule = [[NSNumber alloc] initWithBool:self.useSchedulePlan];
    [APPDELEGATE saveContext];
    
//    [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand setLightScheduleOnOrOff:scheduleSwitch.isOn]];
}

- (void)powerSwitchAction:(UISwitch *)powerSwitch
{
    if (![[BluetoothManager sharedInstance] isConnectedPeripheral]) {
        [MBProgressHUD showError:@"Bluetooth device has been disconnected."];
        return;
    }
    
    [MBProgressHUD showMessage:nil];
//    [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand turnPowerOnorOff:powerSwitch.isOn]];
    __weak typeof(self) weakSelf = self;
    
    [BluetoothManager sharedInstance].timeOutSeconds = 8;
    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand turnPowerOnorOff:!powerSwitch.isOn] onRespond:^BOOL(NSData *data) {
        //判断返回
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
        
        //respond
        Byte value[30] = {0};
        [data getBytes:&value length:sizeof(value)];
        if (value[0] != 0xaa || value[1] != 0x0a) {
            //error
//            [MBProgressHUD showError:@"Response time out."];
            return NO;
        }
        else {
            powerSwitch.on = !powerSwitch.isOn;
            weakSelf.light.isPowerOn = [[NSNumber alloc] initWithBool:powerSwitch.isOn];
            [APPDELEGATE saveContext];
            return YES;
        }
        
    } onTimeOut:^{
        //timeOut
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
//            [MBProgressHUD showError:@"No Response."];
        });
    }];
    
    
}

- (void)showTheme
{
    LightController *light = self.light;
    if (!light) {
//        [MBProgressHUD showError:@"获取对象失败"];
        return;
    }
    
    NSMutableArray *themeNameArray = [[NSMutableArray alloc] init];
    
    //添加缺省主题
    for (NSDictionary *dic in self.defualtThemesArray) {
        
        NSString *themeName = [dic objectForKey:@"name"];
        Theme *newTheme = [Theme addThemeWithName:themeName withLightController:light inManageObjectContext:APPDELEGATE.managedObjectContext];
        newTheme.isDefualt = [[NSNumber alloc] initWithBool:YES];
        
        UIColor *themeColor = [dic objectForKey:@"color"];
        NSString *warmValue = [dic objectForKey:@"warm"];
        
        //添加对应通道
        for (int i = 1; i < 11; i++) {
            Channel *newChannel = [Channel addChannelWithName:[NSString stringWithFormat:@"Ch.%d", i] withTheme:newTheme inManageObjectContext:APPDELEGATE.managedObjectContext];
            newChannel.firstColorValue = [UIColor hexFromUIColor:themeColor];
            newChannel.warmValue = warmValue;
            newChannel.index = [[NSNumber alloc] initWithInt:i];
        }
        
//        [themeNameArray addObject:[dic objectForKey:@"name"]];
    }
    [APPDELEGATE saveContext];
    
    //添加数据库主题
    NSArray *themeArray = [Theme fetchThemesWithLightController:light inManageObjectContext:APPDELEGATE.managedObjectContext];
    for (Theme *curTheme in themeArray) {
        [themeNameArray addObject:curTheme.name];
    }
    
    if (!self.themeDropdownListView) {
        self.themeDropdownListView = [[DropdownListView alloc] init];
        self.themeDropdownListView.delegate = self;
    }
 
    self.themeDropdownListView.dataArray = themeNameArray;
    [self.themeDropdownListView showAtCenter];
}

- (void)changeThemeAction:(Theme *)theme
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hud.labelText = @"Updating...";
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *channelsArray = [Channel getChannelWithTheme:theme inManageObjectContext:APPDELEGATE.managedObjectContext];
        
        float progress = 0.0f;
        NSInteger index = 1;
        [self.selThemeChannelArray removeAllObjects];
        for (Channel *channel in channelsArray) {
            
            [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand setTheColorThemeWithChannel:[Channel convertToModel:channel]]];
            
            [self.selThemeChannelArray addObject:[[ChannelModel alloc] initWithChannel:channel]];
            
            progress = ((float)(index) / (float)channelsArray.count);
            dispatch_async(dispatch_get_main_queue(), ^{
                // Instead we could have also passed a reference to the HUD
                // to the HUD to myProgressTask as a method parameter.
                [MBProgressHUD HUDForView:self.navigationController.view].progress = progress;
            });
            index++;
            
            [NSThread sleepForTimeInterval:0.5];
        }
        
        //发送完成命令
        [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand compeleteCommandOnUseSchedulePlan:NO] withIdentifier:self.light.identifier];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hud hide:YES];
            _hud =nil;
            //        [MBProgressHUD showSuccess:@"Complete"];
        });
    });
    
//    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand compeleteCommandOnUseSchedulePlan:NO] onRespond:^(NSData *data) {
//        //
//        Byte value[30] = {0};
//        [data getBytes:&value length:sizeof(value)];
//        if (value[0] != 0xaa || value[1] != 0x0a) {
//            //error
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD showError:@"Response error."];
//            });
//        }
//        else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //main
//                [MBProgressHUD hideHUD];
//            });
//        }
//        
//    } onTimeOut:^{
//        //time out
//        //主线程更新
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //                [MBProgressHUD hideHUD];
//            [MBProgressHUD showError:@"No Response."];
//        });
//    }];
    
}

- (void)selectDefualtThemeAction:(NSInteger)index
{
    [MBProgressHUD showMessage:nil];
    
    NSDictionary *dic = [self.defualtThemesArray objectAtIndex:index];
//    UIColor *themeColor = [dic objectForKey:@"color"];
//    NSString *warmValue = [dic objectForKey:@"warm"];
    
//    self.selectedTheme = [self.defualtThemesArray objectAtIndex:index];
    self.themeComboxView.contentText = [dic objectForKey:@"name"];
    
    
//    [self.selThemeChannelArray removeAllObjects];
//    
//    for (int i = 1; i < 11; i++) {
//        ChannelModel *model = [[ChannelModel alloc] init];
//        model.index = i;
//        model.name = [NSString stringWithFormat:@"Ch.%d", i];
//        model.color = themeColor;
////        model.subColor = themeColor;
//        model.warmValue = warmValue;
////        model.subWarmValue = warmValue;
//        
//        [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand setTheColorThemeWithChannel:model]];
//        
//        [self.selThemeChannelArray addObject:model];
//        [NSThread sleepForTimeInterval:0.5];
//    }
 
    [MBProgressHUD hideHUD];
}

- (void)changeThemeNotify:(NSNotification *)notify
{
    NSInteger index = [[notify.userInfo objectForKey:@"index"] integerValue];


    NSArray *themeArray = [Theme fetchThemesWithLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
    self.selectedTheme = [themeArray objectAtIndex:index];
    self.themeComboxView.contentText = self.selectedTheme.name;
    self.light.themeName = self.selectedTheme.name;
    
    NSLog(@"\n== self.light.themeName: %@ ===\n", self.light.themeName);
    [APPDELEGATE saveContext];
    
}

- (void)didSelectedAction:(NSInteger)index
{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSString stringWithFormat:@"%ld", (long)index] forKey:@"index"];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notify_ChangeTheme object:nil userInfo:dic];
    
}



@end
