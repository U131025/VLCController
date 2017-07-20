//
//  EditSimpleScheduleViewController.m
//  VLCController
//
//  Created by mojingyu on 16/1/18.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "EditSimpleScheduleViewController.h"
#import "ZJSwitch.h"
#import "TImePickerView.h"
#import "DropDownListView.h"
#import "Theme+Fetch.h"
#import "SettingViewController.h"
#import "Schedule+Fetch.h"
#import "ScheduleItem+Fetch.h"
#import "ScheduleModel.h"
#import "Channel+Fetch.h"
#import "UIColor+extension.h"

@interface EditSimpleScheduleViewController()<UITableViewDataSource, UITableViewDelegate, DropdownListViewDelegate>

//@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIButton *turnOnTimeButton;
@property (nonatomic, strong) UIButton *turnOffTimeButton;
@property (nonatomic, strong) TimePickerView *timePicker;
@property (nonatomic, strong) NSString *onTimeValue;
@property (nonatomic, strong) NSString *offTimeValue;
@property (nonatomic, strong) NSString *themeName;

@property (nonatomic, strong) NSMutableArray *daysArray;    //of ScheduleItemModel

@property (nonatomic, strong) DropdownListView *themeListView;
@property (nonatomic, strong) NSMutableArray *themeArray;   //of ThemeModel
@property (nonatomic, strong) NSArray *defualtThemesArray;   //缺省的主题
@property (nonatomic, assign) NSInteger themeSelectedIndex;
@property (nonatomic, strong) MyComBoxView *colorThemeComboxView;
@property (nonatomic, strong) ZJSwitch *photoCellSwitch;

@property (nonatomic, assign) BOOL isPhotoCell;
@property (nonatomic, strong) Schedule *schedule;
@end

@interface EditSimpleScheduleViewController ()

@end

@implementation EditSimpleScheduleViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.isPhotoCell = NO;
        self.themeSelectedIndex = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Edit Simple Schedule";
    self.tableView.allowsSelection = NO;
    
    [self loadDataFromDataBase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDataFromDataBase
{
    self.schedule = [Schedule addWithName:SimpleSchedule withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
    self.isPhotoCell = [self.schedule.isPhotoCell boolValue];
    self.onTimeValue = self.schedule.timeOn;
    self.offTimeValue = self.schedule.timeOff;
    
    NSArray *items = [ScheduleItem fetchWithSchedule:self.schedule inManageObjectContext:APPDELEGATE.managedObjectContext];
    if (items.count > 0) {
        [self.daysArray removeAllObjects];
        for (ScheduleItem *item in items) {
            ScheduleItemModel *itemModel = [[ScheduleItemModel alloc] initWithScheduleItem:item];
            [self.daysArray addObject:itemModel];
            if (!self.themeName) {
                self.themeName = itemModel.themeName;
            }
        }
    } else {
        NSArray *itemsArray = @[@{@"name":@"M", @"value":@"1"},
                               @{@"name":@"T", @"value":@"2"},
                               @{@"name":@"W", @"value":@"3"},
                               @{@"name":@"TH", @"value":@"4"},
                               @{@"name":@"F", @"value":@"5"},
                               @{@"name":@"SA", @"value":@"6"},
                               @{@"name":@"SU", @"value":@"7"}];
        [self.daysArray removeAllObjects];
        for (int i = 0; i < itemsArray.count; i++) {
            NSDictionary *dic = [itemsArray objectAtIndex:i];
            ScheduleItemModel *itemModel = [[ScheduleItemModel alloc] init];
            itemModel.name = [NSString stringWithFormat:@"%d", i];
            itemModel.date = [dic objectForKey:@"name"];
            
            [self.daysArray addObject:itemModel];
        }
    }
    
    [self.tableView reloadData];
    
}

- (NSMutableArray *)daysArray
{
    if (!_daysArray) {
        _daysArray = [[NSMutableArray alloc] init];
    }
    return _daysArray;
}

//- (NSArray *)daysArray
//{
//    if (!_daysArray) {
//        _daysArray = @[@{@"name":@"M", @"value":@"1"},
//                       @{@"name":@"T", @"value":@"2"},
//                       @{@"name":@"W", @"value":@"3"},
//                       @{@"name":@"TH", @"value":@"4"},
//                       @{@"name":@"F", @"value":@"5"},
//                       @{@"name":@"SA", @"value":@"6"},
//                       @{@"name":@"SU", @"value":@"7"}];
//    }
//    return _daysArray;
//}

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

- (DropdownListView *)themeListView
{
    if (!_themeListView) {
        _themeListView = [[DropdownListView alloc] init];
        _themeListView.delegate = self;
    }
    return _themeListView;
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

#pragma mark DropdownListViewDelegate
- (void)didSelectedAction:(NSInteger)index
{
    self.themeSelectedIndex = index;
//    if (index < self.defualtThemesArray.count) {
//        //缺省主题
//        NSDictionary *dic = [self.defualtThemesArray objectAtIndex:index];
//        self.themeName = [dic objectForKey:@"name"];
//    } else {
        //自定义主题，数据库
//        index = index - self.defualtThemesArray.count;
        Theme *theme = [self.themeArray objectAtIndex:index];
        self.themeName = theme.name;
//    }
    
    self.colorThemeComboxView.contentText = self.themeName;
}

- (void)selectDefualtThemeAction:(NSInteger)index
{
    [MBProgressHUD showMessage:nil];
    
    NSDictionary *dic = [self.defualtThemesArray objectAtIndex:index];
//    UIColor *themeColor = [dic objectForKey:@"color"];
//    NSString *warmValue = [dic objectForKey:@"warm"];
    
    //    self.selectedTheme = [themeArray objectAtIndex:index];
    self.colorThemeComboxView.contentText = [dic objectForKey:@"name"];
    
//    for (int i = 1; i < 11; i++) {
//        ChannelModel *model = [[ChannelModel alloc] init];
//        model.index = i;
//        model.name = [NSString stringWithFormat:@"Ch.%d", i];
//        model.color = themeColor;
//        //        model.subColor = themeColor;
//        model.warmValue = warmValue;
//        //        model.subWarmValue = warmValue;
//        
////        [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand setTheColorThemeWithChannel:model] withController:nil];
//        
//        [NSThread sleepForTimeInterval:0.5];
//    }
    
//    [MBProgressHUD hideHUD];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 4;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 1;
    }
    
    return 150;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 150)];
    
    if (section == 0) {
        myUILabel *titleLabel = [[myUILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 70)];
        titleLabel.verticalAlignment = VerticalAlignmentMiddle;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = WhiteColor;
        titleLabel.text = @"Select Days of the Week";
        titleLabel.font = Font(18);
        [view addSubview:titleLabel];
        
//        NSArray *daysArray = @[@"M", @"T", @"W", @"TH", @"F", @"SA", @"SU"];
        NSInteger offsetX = 10;
        CGFloat buttonWidth = (ScreenWidth - 20.0) / self.daysArray.count;
        UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(9, CGRectGetMaxY(titleLabel.frame)+5, ScreenWidth-18, buttonWidth)];
        borderView.layer.borderColor = WhiteColor.CGColor;
        borderView.layer.borderWidth = 1;
        [view addSubview:borderView];
        
        for (int i = 0; i < self.daysArray.count; i++) {
            ScheduleItemModel *itemModel = [self.daysArray objectAtIndex:i];
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, CGRectGetMaxY(titleLabel.frame)+5, buttonWidth, buttonWidth)];
            button.tag = i;
            [button addTarget:self action:@selector(daySelectAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitleColor:WhiteColor forState:UIControlStateNormal];
            [button setTitle:itemModel.date forState:UIControlStateNormal];
            
            [view addSubview:button];
            [self setButtonSelected:button isSelected:itemModel.isSelected];
            
            if (i != self.daysArray.count - 1) {
                UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button.frame), CGRectGetMinY(borderView.frame), 1, CGRectGetHeight(borderView.frame))];
                line.backgroundColor = WhiteColor;
                [view addSubview:line];
            }
            
            offsetX = CGRectGetMaxX(button.frame)+1;
        }
    } else if (section == 1) {
        view.backgroundColor = WhiteColor;
        view.frame = (CGRect){0, 0, ScreenWidth, 1};
    } else if (section == 2) {
        UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 30, ScreenWidth-100, 50)];
        saveButton.layer.borderWidth = 1;
        saveButton.layer.borderColor = WhiteColor.CGColor;
        [saveButton setTitle:@"Save Schedule" forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:saveButton];
    }
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
    cell.backgroundColor = [UIColor clearColor];
        
    myUILabel *titleLabel = [[myUILabel alloc] initWithFrame:CGRectMake(20, 0, ScreenWidth-140, 60)];
    [cell.contentView addSubview:titleLabel];
    titleLabel.verticalAlignment = VerticalAlignmentMiddle;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = WhiteColor;
    
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
        
        if (self.onTimeValue) {
            [timeButton setTitle:self.onTimeValue forState:UIControlStateNormal];
        }
        
    } else if (indexPath.row == 1) {
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
    } else if (indexPath.row == 2) {
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
    } else if (indexPath.row == 3) {
        titleLabel.text = @"Color Theme";
        
        //comboxview
        MyComBoxView *colorThemeComboxView = [[MyComBoxView alloc] initWithFrame:CGRectMake(ScreenWidth-140, 10, 120, 40)];
        
        if (self.themeName) {
            colorThemeComboxView.contentText = self.themeName;
        }
        
        colorThemeComboxView.clickActionBlock = ^(BOOL isExpand) {
            [self showThemeListView];
        };
        self.colorThemeComboxView = colorThemeComboxView;
        [cell.contentView addSubview:colorThemeComboxView];
        
        
    }
    
    if (indexPath.section != 3) {
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, ScreenWidth, 1)];
        line.backgroundColor = WhiteColor;
        [cell.contentView addSubview:line];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectedBackgroundView.backgroundColor = RGBAlphaColor(255, 255, 255, 0.3);
}

#pragma mark Actions
- (void)showThemeListView
{
    [self loadThemeData];
    
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
//    for (NSDictionary *dic in self.defualtThemesArray) {
//        [nameArray addObject:[dic objectForKey:@"name"]];
//    }
    
    for (Theme *theme in self.themeArray) {
        [nameArray addObject:theme.name];
    }
    
    self.themeListView.dataArray = nameArray;
    [self.themeListView showAtCenter];
}

- (void)photoCellValueChange:(UISwitch *)photoCellSwitch
{
    self.isPhotoCell = photoCellSwitch.isOn;
    //
    if (photoCellSwitch.isOn) {
        // 将on time 置灰
        self.turnOnTimeButton.enabled = NO;
        self.turnOnTimeButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [self.turnOnTimeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    } else {
        self.turnOnTimeButton.enabled = YES;
        self.turnOnTimeButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.turnOnTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
}

- (void)saveAction
{
    if (!self.onTimeValue && !self.isPhotoCell) {
        [MBProgressHUD showError:@"Please selecte time light turn on."];
        return;
    }
    
    if (!self.offTimeValue) {
        [MBProgressHUD showError:@"Please selecte time light turn off."];
        return;
    }
    
    if (!self.themeName) {
        [MBProgressHUD showError:@"Please select a theme."];
        return;
    }
    
    [MBProgressHUD showMessage:@"Waiting..."];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //save
        Schedule *schedule = [Schedule addWithName:SimpleSchedule withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
        schedule.timeOn = self.onTimeValue;
        schedule.timeOff = self.offTimeValue;
        schedule.isPhotoCell = [[NSNumber alloc] initWithBool:self.photoCellSwitch.isOn];
        schedule.isCustomSchedule = 0;
        
        NSArray *tempArray = [NSArray arrayWithArray:self.daysArray];
        for (int i = 0; i < tempArray.count; i++) {
            
            ScheduleItemModel *itemModel = [tempArray objectAtIndex:i];
            //选中的星期数
            ScheduleItem *item = [ScheduleItem addWithName:itemModel.name withSchedule:schedule inManageObjectContext:APPDELEGATE.managedObjectContext];
            item.date = itemModel.date;
            item.themeName = self.themeName;
            item.isSelected = [[NSNumber alloc] initWithBool:itemModel.isSelected];
        }
        [APPDELEGATE saveContext];
        
        //发送设置命令
//        [self setSimpleSchedulePlan];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"Save Success!"];
            
            //设置完毕返回
            [self returnViewController:[SettingViewController class]];
        });
        
    });
}

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

- (TimePickerView *)timePicker
{
    if (!_timePicker) {
        _timePicker = [[TimePickerView alloc] init];
        
    }
    return _timePicker;
}

- (void)daySelectAction:(UIButton *)button
{
//    button.selected = !button.isSelected;
    [self setButtonSelected:button isSelected:!button.isSelected];
}

- (void)setButtonSelected:(UIButton *)button isSelected:(BOOL)selected
{
    button.selected = selected;
    if (button.isSelected) {
        button.backgroundColor = RGBAlphaColor(255, 255, 255, 0.6);
    } else {
        button.backgroundColor = [UIColor clearColor];
    }
    
    ScheduleItemModel *itemModel = [self.daysArray objectAtIndex:button.tag];
    itemModel.isSelected = button.isSelected;
}

- (void)setSimpleSchedulePlan
{

    //计划
    Schedule *simpleSchedule = [Schedule getWithWithName:SimpleSchedule withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
    
    NSArray *items = [ScheduleItem fetchWithSchedule:simpleSchedule inManageObjectContext:APPDELEGATE.managedObjectContext];
    
    if (items == 0) {
        //        [MBProgressHUD hideHUD];
        //        [MBProgressHUD showError:@"Please edit simple schedule."];
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
            
            NSString *timeOnBtye = [self getByteTimeWithDateString:simpleSchedule.timeOn withFormat:ScheduleTimeFormat];
            NSString *timeOffBtye = [self getByteTimeWithDateString:simpleSchedule.timeOff withFormat:ScheduleTimeFormat];
            
//            [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand updateController:YES withDayIndex:dayIndex withChannel:[[ChannelModel alloc] initWithChannel:channel] withOnTime:timeOnBtye withOffTime:timeOffBtye isPhotoCell:[simpleSchedule.isPhotoCell boolValue]] withIdentifier:self.light.identifier];
            
            [[BluetoothManager sharedInstance] sendData:[LightControllerCommand updateController:YES withDayIndex:dayIndex withChannel:[[ChannelModel alloc] initWithChannel:channel] withOnTime:timeOnBtye withOffTime:timeOffBtye isPhotoCell:[simpleSchedule.isPhotoCell boolValue]] onRespond:nil onTimeOut:nil];
            
            [NSThread sleepForTimeInterval:0.5];
        }
        
        dayIndex++;
    }
    
    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand compeleteCommandOnUseSchedulePlan:[self.light.useLightSchedule boolValue]] onRespond:nil onTimeOut:nil];
    
    
    
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
