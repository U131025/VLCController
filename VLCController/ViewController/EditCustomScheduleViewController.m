//
//  EditCustomScheduleViewController.m
//  VLCController
//
//  Created by mojingyu on 16/1/18.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "EditCustomScheduleViewController.h"
#import "ZJSwitch.h"
#import "TImePickerView.h"
#import "DropDownListView.h"
#import "Theme+Fetch.h"
#import "SettingViewController.h"
#import "ScheduleModel.h"
#import "DateFuncation.h"
#import "Schedule+Fetch.h"
#import "ScheduleItem+Fetch.h"
#import "Channel+Fetch.h"
#import "UIColor+extension.h"
#import "MBProgressHUD+NJ.h"

@interface EditCustomScheduleViewController ()<UITableViewDataSource, UITableViewDelegate, DropdownListViewDelegate>

@property (nonatomic, strong) UIButton *turnOnTimeButton;
@property (nonatomic, strong) UIButton *turnOffTimeButton;
@property (nonatomic, strong) TimePickerView *timePicker;
@property (nonatomic, copy) NSString *onTimeValue;
@property (nonatomic, copy) NSString *offTimeValue;

@property (nonatomic, strong) DropdownListView *themeListView;
@property (nonatomic, strong) NSMutableArray *themeArray;   //of ThemeModel
@property (nonatomic, copy) NSArray *defualtThemesArray;   //缺省的主题
@property (nonatomic, assign) NSInteger themeSelectedIndex;
@property (nonatomic, strong) MyComBoxView *colorThemeComboxView;

@property (nonatomic, strong) NSMutableArray *daysArray; // of ScheduleItemModel
@property (nonatomic, strong) ZJSwitch *photoCellSwitch;
@property (nonatomic, assign) BOOL isPhotoCell;

@property (nonatomic, strong) Schedule *schedule;

@end

@implementation EditCustomScheduleViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.themeSelectedIndex = -1;
        self.isPhotoCell = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Edit Custom Schedule";
    self.tableView.allowsSelection = NO;
    self.tableView.frame = (CGRect){0, NavBarHeight, ScreenWidth, ScreenHeight-NavBarHeight-80};
    
    [self loadDataFromDataBase];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight-75, ScreenWidth, 1)];
    line.backgroundColor = WhiteColor;
    [self.view addSubview:line];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(50, ScreenHeight-65, ScreenWidth-100, 50)];
    saveButton.layer.borderWidth = 1;
    saveButton.layer.borderColor = WhiteColor.CGColor;
    [saveButton setTitle:@"Save Schedule" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (NSMutableArray *)themeArray
{
    if (!_themeArray) {
        _themeArray = [[NSMutableArray alloc] init];
    }
    return _themeArray;
}

- (void)loadThemeData
{
    Theme *finder = [Theme getThemeWithWithName:@"All Red" withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
    if (!finder) {
        // 将默认主题添加到数据库中
        for (NSDictionary *dic in self.defualtThemesArray) {
            Theme *newTheme = [Theme addThemeWithName:[dic objectForKey:@"name"] withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
            newTheme.isDefualt = [[NSNumber alloc] initWithBool:YES];
            
            for (int i = 1; i < 11; i++) {
                ChannelModel *channelmodel = [[ChannelModel alloc] init];
                channelmodel.name = [NSString stringWithFormat:@"Ch.%d", i];
                channelmodel.index = i;
                
                Channel *channel = [Channel addChannelWithName:channelmodel.name withTheme:newTheme inManageObjectContext:APPDELEGATE.managedObjectContext];
                channel.colorName = [dic objectForKey:@"name"];
                channel.firstColorValue = [UIColor hexFromUIColor:[dic objectForKey:@"color"]];
                channel.warmValue = [dic objectForKey:@"warm"];
                channel.index = [[NSNumber alloc] initWithInt:i];
                
            }
            [APPDELEGATE saveContext];
            
        }
    }
    
    NSArray *themesArray = [Theme fetchThemesWithLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
    if (themesArray) {
        self.themeArray = [themesArray copy];
    }
}



- (TimePickerView *)timePicker
{
    if (!_timePicker) {
        _timePicker = [[TimePickerView alloc] init];
        
    }
    return _timePicker;
}

- (NSMutableArray *)daysArray
{
    if (!_daysArray) {
        _daysArray = [[NSMutableArray alloc] init];
    }
    
    return _daysArray;
}

- (void)loadDataFromDataBase
{
    [self load60Days];
}

- (void)load60Days
{
    [self.daysArray removeAllObjects];
    Schedule *schedule = [Schedule addWithName:CustomSchedule withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
    self.schedule = schedule;
    self.onTimeValue = self.schedule.timeOn;
    self.offTimeValue = self.schedule.timeOff;
    self.isPhotoCell = [self.schedule.isPhotoCell boolValue];
    
    NSDate *nextDay = [NSDate date];
//    nextDay = [DateFuncation getNextDate:nextDay];
//    nextDay = [DateFuncation getNextDate:nextDay];
    NSTimeZone* localzone = [NSTimeZone localTimeZone];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setTimeZone:localzone];
    [dateformatter setDateFormat:ScheduleDateFormat];
    
//    NSArray *items = [ScheduleItem fetchWithSchedule:schedule inManageObjectContext:APPDELEGATE.managedObjectContext];
    
//    if (items.count > 0) {
//        for (ScheduleItem *item in items) {
//            
//            ScheduleItemModel *itemModel = [[ScheduleItemModel alloc] initWithScheduleItem:item];
////            itemModel.date = [dateformatter stringFromDate:nextDay];
//
//            [self.daysArray addObject:itemModel];
//            
//            nextDay = [DateFuncation getNextDate:nextDay];
//        }
//    }
//    else {
    
        for (int i = 0; i < 60; i++) {
            
            NSString *currentDate = [dateformatter stringFromDate:nextDay];
            ScheduleItem *item = [ScheduleItem getObjectWithDate:currentDate withSchedule:schedule inManageObjectContext:APPDELEGATE.managedObjectContext];
            
            if (item) {
                ScheduleItemModel *itemModel = [[ScheduleItemModel alloc] initWithScheduleItem:item];
                [self.daysArray addObject:itemModel];

            }
            else {
                ScheduleItemModel *itemModel = [[ScheduleItemModel alloc] init];
                itemModel.name = [NSString stringWithFormat:@"%d", i];
                itemModel.date = [dateformatter stringFromDate:nextDay];
                [self.daysArray addObject:itemModel];
            }
            
            nextDay = [DateFuncation getNextDate:nextDay];
        }
//    }
    
}

#pragma mark Actions
- (DropdownListView *)themeListView
{
    if (!_themeListView) {
        _themeListView = [[DropdownListView alloc] init];
        _themeListView.delegate = self;
    }
    return _themeListView;
}

- (void)showThemeListView
{
    [self loadThemeData];
    
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
//    for (NSDictionary *dic in self.defualtThemesArray) {
//        [nameArray addObject:[dic objectForKey:@"name"]];
//    }
//    
    for (Theme *theme in self.themeArray) {
        [nameArray addObject:theme.name];
    }
    
    self.themeListView.dataArray = nameArray;
    [self.themeListView showAtCenter];
}

- (void)photoCellValueChange:(UISwitch *)photoCellSwitch
{
    [self updateTurnOnTimeButton:photoCellSwitch.isOn];
}

- (void)updateTurnOnTimeButton:(BOOL)isOn
{
    if (isOn) {
        // 将on time 置灰
        self.turnOnTimeButton.enabled = NO;
        self.turnOnTimeButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [self.turnOnTimeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    } else {
        self.turnOnTimeButton.enabled = YES;
        self.turnOnTimeButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.turnOnTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    self.isPhotoCell = isOn;
}

#pragma mark TimePicker
- (void)timePickerAction:(UIButton *)button
{
    [self showDataPicker:button.tag isShow:YES];
}

- (void)showDataPicker:(NSInteger)tag isShow:(BOOL)isShow
{
    
    __weak typeof(self) weakSelf = self;
    self.timePicker.doneActionBlock = ^(NSString *result) {
        
        //返回结果
        if (tag == 0) {
            //on
            weakSelf.onTimeValue = result;
            [weakSelf.turnOnTimeButton setTitle:result forState:UIControlStateNormal];
        } else {
            //off
            weakSelf.offTimeValue = result;
            [weakSelf.turnOffTimeButton setTitle:result forState:UIControlStateNormal];
        }
    };
    
    [self.timePicker show];
    
}

#pragma mark -UITableViewDataSource UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else if (section == 2) {
        return 1;
    }

    return self.daysArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 60;
    }
    return 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView)
    {
        CGFloat sectionHeaderHeight = 60; //sectionHeaderHeight
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 50;
    } else if (indexPath.section == 2) {
        return 120;
    }
    
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
    myUILabel *titleLabel = [[myUILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    titleLabel.text = @"Create a custom schedule";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = Font(16);
    titleLabel.textColor = WhiteColor;
    [view addSubview:titleLabel];
    
    myUILabel *dateTitleLabel = [[myUILabel alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(titleLabel.frame), 100, 30)];
    dateTitleLabel.textColor = WhiteColor;
    dateTitleLabel.font = FontBold(18);
    dateTitleLabel.textAlignment = NSTextAlignmentLeft;
    dateTitleLabel.text = @"DATE";
    [view addSubview:dateTitleLabel];
    
    myUILabel *themeTitleLabel = [[myUILabel alloc] initWithFrame:CGRectMake(ScreenWidth-140, CGRectGetMaxY(titleLabel.frame), 120, 30)];
    themeTitleLabel.textColor = WhiteColor;
    themeTitleLabel.font = FontBold(18);
    themeTitleLabel.textAlignment = NSTextAlignmentLeft;
    themeTitleLabel.text = @"THEME";
    [view addSubview:themeTitleLabel];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
    view.backgroundColor = WhiteColor;
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultCellIdentifier];
    }
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    BOOL showLine = YES;
    
    myUILabel *titleLabel = [[myUILabel alloc] initWithFrame:CGRectMake(20, 0, ScreenWidth-140, 60)];
    [cell.contentView addSubview:titleLabel];
    titleLabel.verticalAlignment = VerticalAlignmentMiddle;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = WhiteColor;
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            titleLabel.text = @"Time Lights Turn On";
            
            //time picker
            UIButton *timeButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth-140, 10, 120, 40)];
            timeButton.layer.borderWidth = 1;
            timeButton.layer.borderColor = WhiteColor.CGColor;
            [timeButton setTitleColor:WhiteColor forState:UIControlStateNormal];
            [timeButton setTitle:@"00:00 AM" forState:UIControlStateNormal];
            timeButton.tag = indexPath.row;
            self.turnOnTimeButton = timeButton;
            [timeButton addTarget:self action:@selector(timePickerAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:timeButton];
            
            [self updateTurnOnTimeButton:self.isPhotoCell];
            
            if (self.onTimeValue) {
                [timeButton setTitle:self.onTimeValue forState:UIControlStateNormal];
            }
            
        }
        else if (indexPath.row == 1) {
            titleLabel.text = @"Time Lights Turn Off";
            
            //time picker
            UIButton *timeButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth-140, 10, 120, 40)];
            timeButton.layer.borderWidth = 1;
            timeButton.layer.borderColor = WhiteColor.CGColor;
            [timeButton setTitle:@"00:00 AM" forState:UIControlStateNormal];
            timeButton.tag = indexPath.row;
            self.turnOffTimeButton = timeButton;
            [timeButton addTarget:self action:@selector(timePickerAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:timeButton];
            
            if (self.offTimeValue) {
                [timeButton setTitle:self.offTimeValue forState:UIControlStateNormal];
            }
            
            //time Picker
        }
        else if (indexPath.row == 2) {
            titleLabel.text = @"PhotoCell";
            
            //switch
            ZJSwitch *photoCellSwitch = [[ZJSwitch alloc] initWithFrame:CGRectMake(ScreenWidth- 100, 10, 80, 40)];
            photoCellSwitch.borderColor = WhiteColor;
            photoCellSwitch.on = NO;
            photoCellSwitch.backgroundColor = [UIColor clearColor];
            
            photoCellSwitch.onText = @"ON";
            photoCellSwitch.offText = @"OFF";
            
            photoCellSwitch.offThumbTiniColor = WhiteColor;
            photoCellSwitch.offTextColor = WhiteColor;
            photoCellSwitch.tintColor = RGBAlphaColor(41, 118, 154, 1);
            
            photoCellSwitch.onThumbTiniColor = RGBAlphaColor(68, 167, 215, 1);
            photoCellSwitch.onTextColor = RGBAlphaColor(68, 167, 215, 1);
            photoCellSwitch.onTintColor = WhiteColor;
            
            [photoCellSwitch addTarget:self action:@selector(photoCellValueChange:) forControlEvents:UIControlEventValueChanged];
            self.photoCellSwitch = photoCellSwitch;
            [cell.contentView addSubview:photoCellSwitch];
            
            [self.photoCellSwitch setOn:self.isPhotoCell];
        }
        
        
    }
    else if (indexPath.section == 1) {
//        if (indexPath.row != (self.daysArray.count-1)) {
//            showLine = NO;
//        }
        showLine = NO;
        
        ScheduleItemModel *itemModel = [self.daysArray objectAtIndex:indexPath.row];
        titleLabel.text = itemModel.date;
        
        MyComBoxView *colorThemeComboxView = [[MyComBoxView alloc] initWithFrame:CGRectMake(ScreenWidth-140, 10, 120, 40)];
        
        if (itemModel.themeName) {
            colorThemeComboxView.contentText = itemModel.themeName;
        }

        __weak typeof(colorThemeComboxView) weakComboxView = colorThemeComboxView;
        colorThemeComboxView.clickActionBlock = ^(BOOL isExpand) {
            self.themeSelectedIndex = indexPath.row;
            self.colorThemeComboxView = weakComboxView;
            [self showThemeListView];
        };
        self.colorThemeComboxView = colorThemeComboxView;
        [cell.contentView addSubview:colorThemeComboxView];
        
    }
//    else if (indexPath.section != 3) {
//        showLine = NO;
//        
//        UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 30, ScreenWidth-100, 60)];
//        saveButton.layer.borderWidth = 1;
//        saveButton.layer.borderColor = WhiteColor.CGColor;
//        [saveButton setTitle:@"Save Schedule" forState:UIControlStateNormal];
//        [saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
//        [cell.contentView addSubview:saveButton];
//    }
    
    if (showLine) {
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, ScreenWidth, 1)];
        line.backgroundColor = WhiteColor;
        [cell.contentView addSubview:line];
    }
    
    return cell;
}

#pragma mark DropdownListViewDelegate
- (void)didSelectedAction:(NSInteger)index
{
    NSString *themeName;
//    if (index < self.defualtThemesArray.count) {
//        //缺省主题
//        NSDictionary *dic = [self.defualtThemesArray objectAtIndex:index];
//        themeName = [dic objectForKey:@"name"];
//    } else {
        //自定义主题，数据库
//        index = index - self.defualtThemesArray.count;
        Theme *theme = [self.themeArray objectAtIndex:index];
        themeName = theme.name;
//    }
    
    ScheduleItemModel *itemModel = [self.daysArray objectAtIndex:self.themeSelectedIndex];
    itemModel.themeName = themeName;
    self.colorThemeComboxView.contentText = themeName;
}

- (void)saveAction
{
    if (!self.onTimeValue && !self.photoCellSwitch.isOn) {
        [MBProgressHUD showError:@"Please selecte time light turn on." toView:self.view];
        return;
    }
    
    if (!self.offTimeValue) {
        [MBProgressHUD showError:@"Please selecte time light turn off." toView:self.view];
        return;
    }
    
    //校验时间
    [MBProgressHUD showMessage:@"Waiting..." toView:self.view];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //
        Schedule *schedule = [Schedule addWithName:CustomSchedule withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
        schedule.timeOn = self.onTimeValue;
        schedule.timeOff = self.offTimeValue;
        schedule.isPhotoCell = [[NSNumber alloc] initWithBool:self.photoCellSwitch.isOn];
        schedule.isCustomSchedule = 0;
        
        //save
        NSArray *tempArray = [NSArray arrayWithArray:self.daysArray];
        for (int i = 0; i < tempArray.count; i++) {
            ScheduleItemModel *itemModel = [tempArray objectAtIndex:i];
            ScheduleItem *item = [ScheduleItem addWithName:itemModel.name withSchedule:schedule inManageObjectContext:APPDELEGATE.managedObjectContext];
            
            if (item) {
                item.name = itemModel.name;
                item.date = itemModel.date;
                item.themeName = itemModel.themeName;
                if (!itemModel.themeName)
                    item.isSelected = [[NSNumber alloc] initWithBool:NO];
                else
                    item.isSelected = [[NSNumber alloc] initWithBool:YES];
            }
            
        }
        
        [APPDELEGATE saveContext];
        
//        [self setCustomSchedulePlan];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showSuccess:@"Save Success!" toView:self.view];
            
            //设置完毕返回
            [self returnViewController:[SettingViewController class]];

        });
    });
    
}

- (void)setCustomSchedulePlan
{
    
    //计划
    Schedule *customSchedule = [Schedule getWithWithName:CustomSchedule withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
    
    NSArray *items = [ScheduleItem fetchWithSchedule:customSchedule inManageObjectContext:APPDELEGATE.managedObjectContext];
    
    if (items == 0) {
         return;
    }
    
    NSInteger dayIndex = 1;
    for (ScheduleItem *item in items) {
        ScheduleItemModel *itemModel = [[ScheduleItemModel alloc] initWithScheduleItem:item];
        
        //获取主题
        Theme *itemTheme = [Theme getThemeWithWithName:itemModel.themeName withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
        
        //通道
        NSArray *channelArray = [Channel getChannelWithTheme:itemTheme inManageObjectContext:APPDELEGATE.managedObjectContext];
        
        for (Channel *channel in channelArray) {
            
            NSString *timeOnBtye = [self getByteTimeWithDateString:customSchedule.timeOn withFormat:ScheduleDateFormat];
            NSString *timeOffBtye = [self getByteTimeWithDateString:customSchedule.timeOff withFormat:ScheduleDateFormat];
            
            [[BluetoothManager sharedInstance] sendData:[LightControllerCommand updateController:NO withDayIndex:dayIndex withChannel:[[ChannelModel alloc] initWithChannel:channel] withOnTime:timeOnBtye withOffTime:timeOffBtye isPhotoCell:[self.light.useLightSchedule boolValue]] onRespond:nil onTimeOut:nil];
            
//            [[BluetoothManager sharedInstance] sendDataToPeripheral: withIdentifier:self.light.identifier];
        }
        
        [NSThread sleepForTimeInterval:0.5];
        
        dayIndex++;
    }
    
    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand compeleteCommandOnUseSchedulePlan:[self.light.useLightSchedule boolValue]] onRespond:nil onTimeOut:nil];
    
//    [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand compeleteCommandOnUseSchedulePlan:[self.light.useLightSchedule boolValue]]];
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
}

@end
