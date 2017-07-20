//
//  UnpairWirelessPlugViewController.m
//  VLCController
//
//  Created by mojingyu on 16/3/7.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "UnpairWirelessPlugViewController.h"
#import "DropDownListView.h"
#import "SettingViewController.h"

@interface UnpairWirelessPlugViewController ()<UITableViewDelegate, UITableViewDataSource, DropdownListViewDelegate>

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) NSArray *plugsArray;
@property (nonatomic, strong) DropdownListView *selectListView;
@property (nonatomic, strong) UIButton *plugSelectedButton;
@end

@implementation UnpairWirelessPlugViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.selectedIndex = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Unpair Wireless Switch";
    
    [self loadPlugsData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectAction:) name:Notify_Disconnect object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)disconnectAction:(NSNotification *)notify
{
    [MBProgressHUD showError:@"Bluetooth device has been disconneted."];
}

//- (NSMutableArray *)plugsArray
//{
//    if (!_plugsArray) {
//        _plugsArray = [[NSMutableArray alloc] init];
//    }
//    return _plugsArray;
//}

- (DropdownListView *)selectListView
{
    if (!_selectListView) {
        _selectListView = [[DropdownListView alloc] init];
        _selectListView.delegate = self;
    }
    return _selectListView;
}

- (void)loadPlugsData
{
    NSArray *lightControllerArray = [LightController getAllLightControllersInManagedObjectContext:APPDELEGATE.managedObjectContext];
    
    self.plugsArray = lightControllerArray;
}

#pragma makr DropdownListViewDelegate
- (void)didSelectedAction:(NSInteger)index
{
    //plug selected action
    LightController *plug = [self.plugsArray objectAtIndex:index];
    self.selectedIndex = index;
    [self.plugSelectedButton setTitle:plug.name forState:UIControlStateNormal];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CGFloat cellHeight = (ScreenHeight - NavBarHeight)/3;
//    if (indexPath.section == 0) {
//        return  250;
//    } else
    if (indexPath.section == 0) {
        return 60;
    } else {
        return 80;
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
//    if (indexPath.section == 0) {
//        
//        myUILabel *tipLabel = [[myUILabel alloc] initWithFrame:CGRectMake(0, 10, ScreenWidth, 30)];
//        tipLabel.text = @"Plugs Detected!";
//        tipLabel.font = FontBold(20);
//        tipLabel.textAlignment = NSTextAlignmentCenter;
//        tipLabel.textColor = WhiteColor;
//        [cell.contentView addSubview:tipLabel];
//        
//        // select plug
//        UIButton *button = [self createDropDownButtonWithView:cell.contentView withFrame:CGRectMake(0, 30, 0, 0) withTitle:@"Please selecte the plugs you wish to unpair." useArrow:YES];
//        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
//        button.tag = indexPath.section;
//        self.plugSelectedButton = button;
//        
//        if (self.selectedIndex != -1) {
//            LightControllerModel *lightCtl = [self.plugsArray objectAtIndex:self.selectedIndex];
//            [button setTitle:lightCtl.name forState:UIControlStateNormal];
//        }
//    }
    if (indexPath.section == 0) {
        
        CGFloat cellHeight = 60;
        myUILabel *tipLabel = [[myUILabel alloc] initWithFrame:CGRectMake(50, 0, ScreenWidth-100, cellHeight)];
        tipLabel.text = @"Please insure the plug you would like to unpair is plugged into an outlet.";
        tipLabel.font = Font(16);
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = WhiteColor;
        tipLabel.numberOfLines = 0;
        [cell.contentView addSubview:tipLabel];
        
    } else if (indexPath.section == 1) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50, 20, ScreenWidth-100, 60)];
        button.layer.borderColor = WhiteColor.CGColor;
        button.layer.borderWidth = 1;
        button.tag = 1;
        [button setTitleColor:WhiteColor forState:UIControlStateNormal];
        [button setTitle:@"Continue" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];
        
    } else if (indexPath.section == 2) {
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 20, ScreenWidth-100, 60)];
        cancelButton.layer.borderColor = WhiteColor.CGColor;
        cancelButton.layer.borderWidth = 1;
        cancelButton.tag = 2;
        [cancelButton setTitleColor:WhiteColor forState:UIControlStateNormal];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:cancelButton];
        
        UIButton *cancelIcon = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMinY(cancelButton.frame), 60, CGRectGetHeight(cancelButton.frame))];
        cancelIcon.tag = 2;
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

- (void)buttonAction:(UIButton *)button
{
    if (button.tag == 0) {
        //select plug
        NSMutableArray *nameArray = [[NSMutableArray alloc] init];
        for (LightController *plug in self.plugsArray) {
            [nameArray addObject:plug.name];
        }
        self.selectListView.dataArray = nameArray;
        [self.selectListView showAtCenter];
        
    }  else if (button.tag == 1) {
        [self unpairWireless];
        
    } else if (button.tag == 2) {
        //Cancel
        //return to controller setting view
        [self returnViewController:[SettingViewController class]];
    }
}

- (void)unpairWireless
{
//    if (self.selectedIndex) {
//        [MBProgressHUD showError:@"Please select a plug."];
//        return;
//    }
    
    //发送取消配对插头命令
//    [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand unpairWirelessPlug] withIdentifier:self.light.identifier];
    
    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand unpairWirelessPlug:self.light.lightID] onRespond:^BOOL(NSData *data) {
        //respond
        return YES;
        
    } onTimeOut:^{
        //time out
        
    }];
    
    //
    TipMessageView *tip = [[TipMessageView alloc] init];
    tip.headTitleText = @"Unpair Wireless Switch";
    tip.tiptilteText = @"Success!";
    tip.tipDetailText = @"Your wireless switch has been unpaired.";
    tip.okButtonContent = @"Return";
    tip.cancelButtonContent = nil;
    
    tip.okActionBlock = ^() {
        
        //
        [self returnViewController:[SettingViewController class]];
    };
    
    [tip show];
}

@end
