//
//  DuplicateControllerViewController.m
//  VLCController
//
//  Created by mojingyu on 16/1/15.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "DuplicateControllerViewController.h"
#import "DropDownListView.h"
#import "SettingViewController.h"

typedef enum
{
    None,
    MasterSelected,
    SlaveSelected,
}SelectedType;

@interface DuplicateControllerViewController ()<UITableViewDataSource, UITableViewDelegate, DropdownListViewDelegate>
@property (nonatomic, assign) NSInteger masterSelectedIndex;
@property (nonatomic, assign) NSInteger slaveSelectedIndex;

@property (nonatomic, strong) DropdownListView *selectListView;
@property (nonatomic, assign) SelectedType selectType;
@property (nonatomic, strong) LightController *masterSelected;
@property (nonatomic, strong) LightController *slaveSelected;

@property (nonatomic, strong) UIButton *masterSelectedButton;
@property (nonatomic, strong) UIButton *slaveSelectedButton;
@end

@implementation DuplicateControllerViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.selectType = None;
        self.masterSelectedIndex = -1;
        self.slaveSelectedIndex = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Duplicate Controller";
    self.tableView.allowsSelection = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DropdownListView *)selectListView
{
    if (!_selectListView) {
        _selectListView = [[DropdownListView alloc] init];
        _selectListView.delegate = self;
    }
    
    return _selectListView;
}

#pragma mark DropdownListViewDelegate
- (void)didSelectedAction:(NSInteger)index
{
    LightController *selectedController = [self.controllerArray objectAtIndex:index];
    if (self.selectType == MasterSelected) {
        
        if ([self.slaveSelected isEqual:selectedController]) {
            [MBProgressHUD showError:@"This controller has been a slave."];
            return;
        }
        self.masterSelectedIndex = index;
        self.masterSelected = selectedController;
        [self.masterSelectedButton setTitle:self.masterSelected.name forState:UIControlStateNormal];
    } else if (self.selectType == SlaveSelected) {
        if ([self.masterSelected isEqual:selectedController]) {
            [MBProgressHUD showError:@"This controller has been a master."];
            return;
        }
        
        self.slaveSelectedIndex = index;
        self.slaveSelected = selectedController;
        [self.slaveSelectedButton setTitle:self.slaveSelected.name forState:UIControlStateNormal];
    }
}

- (BOOL)checkMasterSlaveController
{
    if ([self.masterSelected isEqual:self.slaveSelected]) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = (ScreenHeight - NavBarHeight)/4;
    if (indexPath.section == 0 || indexPath.section == 1) {
        return  cellHeight;
    } else {
        return 100;
    }
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
    
    //
    if (indexPath.section == 0) {
        // select master
        UIButton *masterButton = [self createDropDownButtonWithView:cell.contentView withFrame:CGRectMake(0, 0, 0, 0) withTitle:@"Select a controller to become a \"master\"." useArrow:YES];
        [masterButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        masterButton.tag = indexPath.section;
        self.masterSelectedButton = masterButton;
        
        if (self.masterSelectedIndex != -1) {
            LightControllerModel *lightCtl = [self.controllerArray objectAtIndex:self.masterSelectedIndex];
            [masterButton setTitle:lightCtl.name forState:UIControlStateNormal];
        }
    } else if (indexPath.section == 1) {
        UIButton *slaveButton = [self createDropDownButtonWithView:cell.contentView withFrame:CGRectMake(0, 0, 0, 0) withTitle:@"Select a controller to become a \"slave\"." useArrow:YES];
        [slaveButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        slaveButton.tag = indexPath.section;
        self.slaveSelectedButton = slaveButton;
        
        if (self.slaveSelectedIndex != -1) {
            LightControllerModel *lightCtl = [self.controllerArray objectAtIndex:self.slaveSelectedIndex];
            [slaveButton setTitle:lightCtl.name forState:UIControlStateNormal];
        }
    } else if (indexPath.section == 2) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50, 40, ScreenWidth-100, 60)];
        button.layer.borderColor = WhiteColor.CGColor;
        button.layer.borderWidth = 1;
        button.tag = indexPath.section;
        [button setTitleColor:WhiteColor forState:UIControlStateNormal];
        [button setTitle:@"Continue" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];
    } else if (indexPath.section == 3) {
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 20, ScreenWidth-100, 60)];
        cancelButton.layer.borderColor = WhiteColor.CGColor;
        cancelButton.layer.borderWidth = 1;
        cancelButton.tag = indexPath.section;
        [cancelButton setTitleColor:WhiteColor forState:UIControlStateNormal];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:cancelButton];
        
        UIButton *cancelIcon = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMinY(cancelButton.frame), 60, CGRectGetHeight(cancelButton.frame))];
        cancelIcon.tag = indexPath.section;
        [cancelIcon setTitle:@"✕" forState:UIControlStateNormal];
        cancelIcon.titleLabel.font = Font(30);
        [cancelIcon setTitleColor:WhiteColor forState:UIControlStateNormal];
        [cancelIcon addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:cancelIcon];
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cancelIcon.frame), CGRectGetMinY(cancelIcon.frame), 1, CGRectGetHeight(cancelIcon.frame))];
        line.backgroundColor = WhiteColor;
        [cell.contentView addSubview:line];

    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSMutableArray *)getControllerNameArray
{
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    for (LightController *lightController in self.controllerArray) {
        
//        if (self.masterSelected && [self.masterSelected isEqual:lightController]) {
//            continue;
//        }
//        
//        if (self.slaveSelected && [self.slaveSelected isEqual:lightController]) {
//            continue;
//        }
        
        [nameArray addObject:lightController.name];
    }
    return nameArray;
}

- (void)buttonAction:(UIButton *)button
{
    if (button.tag == 0) {
        //select master
        self.selectType = MasterSelected;
        self.masterSelected = nil;
        self.selectListView.titleText = @"Please select a controll to become \"master\"";
        self.selectListView.dataArray = [self getControllerNameArray];
        [self.selectListView showAtCenter];
        
    } else if (button.tag == 1) {
        //select slave
        self.selectType = SlaveSelected;
        self.slaveSelected = nil;
        self.selectListView.titleText = @"Please select a controll to become \"slave\"";
        self.selectListView.dataArray = [self getControllerNameArray];
        [self.selectListView showAtCenter];
        
    } else if (button.tag == 2) {
        if (![self checkMasterSlaveController]) {
            [MBProgressHUD showError:@"This controller has been a master."];
            return;
        }
        
        [self checkSyncController];
        
    } else if (button.tag == 3) {
        //Cancel
        //return to controller setting view
        [self returnViewController:[HomeViewController class]];
    }
}

- (void)checkSyncController
{
    if (self.masterSelectedIndex == -1) {
        [MBProgressHUD showError:@"Please select a master."];
        return;
    }
    
    if (self.slaveSelectedIndex == -1) {
        [MBProgressHUD showError:@"Please select a slave."];
        return;
    }
    
    LightControllerModel *master = [self.controllerArray objectAtIndex:self.masterSelectedIndex];
//    LightControllerModel *slave = [self.controllerArray objectAtIndex:self.slaveSelectedIndex];
    
    //Continue
    TipMessageView *tip = [[TipMessageView alloc] init];
    tip.headTitleText = @"Duplicate Controller";
    tip.tiptilteText = [NSString stringWithFormat:@"%@:", master.name];
    tip.tipDetailText = @"You selected \"slave\" controller will inherit all the settings of the \"master\" controller.\n You \"slave\" controller must be placed within 50ft. of the master controller to sync and continue to recieves updates.";
    tip.okButtonContent = @"Continue";
    tip.cancelButtonContent = @"Cancel";
    tip.isCancelIcon = YES;
    
    tip.okActionBlock = ^() {
        
        //调用蓝牙接口设置设置灯泡命令
        [self syncController];
    };
    
    [tip show];
}

- (void)syncController
{
    //发送蓝牙命令
    [self syncControllerAction];
}

- (void)syncControllerAction
{
    
    
    //更新至数据库
    if (self.masterSelected) {
        LightController *master = [LightController getObjectWithIdentifier:self.masterSelected.identifier inManagedObjectContext:APPDELEGATE.managedObjectContext];
        LightController *slave = [LightController getObjectWithIdentifier:self.slaveSelected.identifier inManagedObjectContext:APPDELEGATE.managedObjectContext];
        
        master.slave = slave;
        slave.master = master;
        [APPDELEGATE saveContext];
        
        //配对指令
        [[BluetoothManager sharedInstance] sendData:[LightControllerCommand pairSlaveControllerCommand:master.lightID] onRespond:nil onTimeOut:nil];
        
//        [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand pairSlaveControllerCommand:master.lightID]];
    }
    
    //提示
    TipMessageView *tip = [[TipMessageView alloc] init];
    tip.headTitleText = @"Controller Sync";
    tip.tiptilteText = @"Success!";
    tip.tipDetailText = @"A duplic controller has been created.\nThe selected controller is now linked to the \"master\" controller.Any changes to the \"master\" will update the \"slave\".\nIf the \"slave\" is out of the range of the \"master\",please move closer or unlink the controller and control seperately.";
    tip.okButtonContent = @"Return";
    tip.isCancelIcon = YES;
    
    tip.okActionBlock = ^() {
        
        [self returnViewController:[HomeViewController class]];
    };
    
    [tip show];
}

@end
