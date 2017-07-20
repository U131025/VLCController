//
//  ScheduleOptionViewController.m
//  VLCController
//
//  Created by mojingyu on 16/1/18.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ScheduleOptionViewController.h"
#import "TextTableViewCell.h"
#import "EditSimpleScheduleViewController.h"
#import "EditCustomScheduleViewController.h"
#import "ZJSwitch.h"

@interface ScheduleOptionViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation ScheduleOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Schedule";
    [self.tableView registerClass:[TextTableViewCell class] forCellReuseIdentifier:@"TextWithArrowCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 130;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, 30)];
        titleLabel.text = @"Choose Schedule Type";
        titleLabel.font = Font(18);
        titleLabel.textColor = WhiteColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:titleLabel];
        
        //Switch
        ZJSwitch *typeSwitch = [[ZJSwitch alloc] initWithFrame:CGRectMake(view.center.x - 30, CGRectGetMaxY(titleLabel.frame)+20, 60, 40)];
        
        if (self.light) {
            typeSwitch.on = [self.light.isCustomSchedule boolValue];
        } else {
            typeSwitch.on = NO;
        }
        
        typeSwitch.backgroundColor = [UIColor clearColor];
        typeSwitch.borderColor = WhiteColor;
        typeSwitch.thumbTintColor = WhiteColor;
        typeSwitch.tintColor = RGBAlphaColor(41, 118, 154, 1);
        typeSwitch.onTintColor = RGBAlphaColor(41, 118, 154, 1);
        [typeSwitch addTarget:self action:@selector(typeValueChange:) forControlEvents:UIControlEventValueChanged];
        [view addSubview:typeSwitch];
        
        //
        UILabel *simpleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(typeSwitch.frame)-120, CGRectGetMinY(typeSwitch.frame), 100, CGRectGetHeight(typeSwitch.frame))];
        simpleLabel.textAlignment = NSTextAlignmentRight;
        simpleLabel.text = @"Simple";
        simpleLabel.textColor = WhiteColor;
        simpleLabel.font = Font(16);
        [view addSubview:simpleLabel];
        
        UILabel *customLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(typeSwitch.frame)+20, CGRectGetMinY(simpleLabel.frame), CGRectGetWidth(simpleLabel.frame), CGRectGetHeight(simpleLabel.frame))];
        customLabel.textColor = WhiteColor;
        customLabel.textAlignment = NSTextAlignmentLeft;
        customLabel.text = @"Custom";
        customLabel.font = Font(16);
        [view addSubview:customLabel];
        
        return view;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"TextWithArrowCell";
    TextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    cell.backgroundColor = [UIColor clearColor];
    cell.isTopLine = YES;
    
    if (indexPath.row == 0) {
        cell.titleText = @"Edit Simple Schedule";
    } else {
        cell.titleText = @"Edit Custom Schedule";
        cell.isBottomLine = YES;
    }
    
    cell.isArrow = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        //simple schedule
        EditSimpleScheduleViewController *simpleVC = [[EditSimpleScheduleViewController alloc] init];
        simpleVC.light = self.light;
        [self.navigationController pushViewController:simpleVC animated:YES];
        
    } else if (indexPath.row == 1) {
        //custom schedule
        EditCustomScheduleViewController *customVC = [[EditCustomScheduleViewController alloc] init];
        customVC.light = self.light;
        [self.navigationController pushViewController:customVC animated:YES];
    }
}

#pragma mark SwitchValueChange
- (void)typeValueChange:(UISwitch *)typeSwitch
{
    //
    if (typeSwitch.isOn) {
        APPDELEGATE.scheduleType = Schedule_Simple;
    } else {
        APPDELEGATE.scheduleType = Schedule_Custom;
    }
    
    if (self.light) {
        self.light.isCustomSchedule = [[NSNumber alloc] initWithBool:typeSwitch.isOn];
    }
    [APPDELEGATE saveContext];
}

@end
