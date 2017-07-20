//
//  AssignBulbChannelViewController.m
//  VLCController
//
//  Created by mojingyu on 16/3/4.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "AssignBulbChannelViewController.h"
#import "DropDownListView.h"
#import "SettingViewController.h"
#import "NSString+Extension.h"

typedef enum
{
    None,
    BulbsSeleted,
    ChannelSeleted,
}SelectedType;

@interface AssignBulbChannelViewController ()<UITableViewDataSource, UITableViewDelegate, DropdownListViewDelegate>

@property (nonatomic, strong) DropdownListView *selectedListView;
@property (nonatomic, strong) NSArray *bulbsArray;
@property (nonatomic, assign) SelectedType selectedType;
@property (nonatomic, assign) NSInteger bulbsSelectedIndex;
@property (nonatomic, assign) NSInteger channelSelectedIndex;
@end

@implementation AssignBulbChannelViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.selectedType = None;
        self.bulbsSelectedIndex = -1;
        self.channelSelectedIndex = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Change/Assign Bulb Channel";
    self.tableView.allowsSelection = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DropdownListView *)selectedListView
{
    if (!_selectedListView) {
        _selectedListView = [[DropdownListView alloc] init];
        _selectedListView.delegate = self;
    }
    return _selectedListView;
}

- (NSArray *)bulbsArray
{
    if (!_bulbsArray) {
        _bulbsArray = @[@{@"name":@"All Unassigned Bulbs", @"value":@"0x00"},
                        @{@"name":@"All Bulbs", @"value":@"0xff"},
                        @{@"name":@"Channel 1 Only", @"value":@"0x01"},
                        @{@"name":@"Channel 2 Only", @"value":@"0x02"},
                        @{@"name":@"Channel 3 Only", @"value":@"0x03"},
                        @{@"name":@"Channel 4 Only", @"value":@"0x04"},
                        @{@"name":@"Channel 5 Only", @"value":@"0x05"},
                        @{@"name":@"Channel 6 Only", @"value":@"0x06"},
                        @{@"name":@"Channel 7 Only", @"value":@"0x07"},
                        @{@"name":@"Channel 8 Only", @"value":@"0x08"},
                        @{@"name":@"Channel 9 Only", @"value":@"0x09"},
                        @{@"name":@"Channel 10 Only", @"value":@"0x0a"}];
    }
    return _bulbsArray;
}

- (NSMutableArray *)channelArray
{
    if (!_channelArray) {
        _channelArray = [[NSMutableArray alloc] init];
    }
    return _channelArray;
}

#pragma mark UITableViewDataSource
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
    CGFloat cellHeight = (ScreenHeight - NavBarHeight) / 3;
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cellview = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
    if (!cellview) {
        cellview = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultCellIdentifier];
    }
    for (UIView *subView in cellview.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    NSString *name;
    NSString *title;
    if (indexPath.section == 0) {
        title = @"Select the bulbs you want to update.";
        
        if (self.bulbsSelectedIndex != -1) {
            NSDictionary *dic = [self.bulbsArray objectAtIndex:self.bulbsSelectedIndex];
            name = [dic objectForKey:@"name"];
        }
        
    } else if (indexPath.section == 1) {
        title = @"Select the channel you want to update the selected bulbs to.";
        
        if (self.channelSelectedIndex != -1) {
            ChannelModel *channel = [self.channelArray objectAtIndex:self.channelSelectedIndex];
            name = channel.name;
        }
        
    } else if (indexPath.section == 2) {
        title = @"NOTE:All bulbs must be plugged into the controller, on linked slave controller or a paired wireless switch.";
    }
    
    CGFloat rowHeight = 80;
    myUILabel *topLabel = [[myUILabel alloc] initWithFrame:CGRectMake(50, 0, ScreenWidth-100, rowHeight)];
    topLabel.verticalAlignment = VerticalAlignmentBottom;
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.textColor = WhiteColor;
    topLabel.font = Font(15);
    topLabel.text = title;
    topLabel.numberOfLines = 0;
    [cellview.contentView addSubview:topLabel];
    
    UIButton *selectControllerButton = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(topLabel.frame)+10, ScreenWidth-100, 60)];
    selectControllerButton.layer.borderColor = WhiteColor.CGColor;
    selectControllerButton.layer.borderWidth = 1;
    if (name)
        [selectControllerButton setTitle:name forState:UIControlStateNormal];
    
    selectControllerButton.tag = indexPath.section;
    [selectControllerButton setTitleColor:WhiteColor forState:UIControlStateNormal];
    [selectControllerButton addTarget:self action:@selector(dropButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    _selectControllerButton = selectControllerButton;
    if (indexPath.section == 2) {
        [selectControllerButton setTitle:@"Set Bulbs" forState:UIControlStateNormal];
    }
    
    [cellview.contentView addSubview:selectControllerButton];
    
    if (indexPath.section != 2) {
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(selectControllerButton.frame)-40, CGRectGetMaxY(selectControllerButton.frame)-CGRectGetHeight(selectControllerButton.frame)/2 - 15, 30, 30)];
        arrowImageView.image = [UIImage imageNamed:@"downArrow"];
        [cellview.contentView addSubview:arrowImageView];
    }
    
    cellview.backgroundColor = [UIColor clearColor];
    return cellview;
}

- (void)dropButtonClick:(UIButton *)button
{
    if (button.tag == 0) {
        //select bulbs
        self.selectedType = BulbsSeleted;
        
        NSMutableArray *nameArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in self.bulbsArray) {
            [nameArray addObject:[dic objectForKey:@"name"]];
        }
        
        self.selectedListView.dataArray = [nameArray copy];
        [self.selectedListView showAtCenter];
        
    } else if (button.tag == 1) {
        //select channel
        self.selectedType = ChannelSeleted;
        NSMutableArray *nameArray = [[NSMutableArray alloc] init];
        for (ChannelModel *channel in self.channelArray) {
            [nameArray addObject:channel.name];
        }
        self.selectedListView.dataArray = [nameArray copy];
        [self.selectedListView showAtCenter];
        
    } else {
        //set bulbs
        [self setbulbsAction];
    }
}

- (void)setbulbsAction
{
    if (self.bulbsSelectedIndex == -1) {
        [MBProgressHUD showError:@"Please select the bulbs you want to update."];
        return;
    }
    
    if (self.channelSelectedIndex == -1) {
        [MBProgressHUD showError:@"Please select the bulbs you want to update."];
        return;
    }
    
    if (![[BluetoothManager sharedInstance] isConnectedPeripheral]) {
        [MBProgressHUD showError:@"Bluetooth device has been disconnected."];
        return;
    }
    
    NSDictionary *bulbDictionary = [self.bulbsArray objectAtIndex:self.bulbsSelectedIndex];
    ChannelModel *channel = [self.channelArray objectAtIndex:self.channelSelectedIndex];
    
    TipMessageView *tip = [[TipMessageView alloc] init];
    tip.headTitleText = @"Assign Bulb Channel";
    tip.tiptilteText = @"Are you sure?";
    NSString *tipText = [NSString stringWithFormat:@"You are updating \"%@\" to \"%@\".", [bulbDictionary objectForKey:@"name"], channel.name];
    tip.tipDetailText = tipText;
    tip.okButtonContent = @"Continue";
    tip.cancelButtonContent = @"Cancel";
    tip.isCancelIcon = YES;
    
    tip.okActionBlock = ^() {
        
        //调用蓝牙接口设置设置灯泡命令
        [self setBulbsAction];
    };
    
    [tip show];
}

- (void)setBulbsAction
{
    if (![[BluetoothManager sharedInstance] isConnectedPeripheral]) {
        [MBProgressHUD showError:@"Bluetooth device has been disconnected."];
        return;
    }
    
    [MBProgressHUD showMessage:nil];
    
    __weak typeof(self) weakSelf = self;
    [self setBulbsCommand:^{
        //finishBlock
        [MBProgressHUD hideHUD];
        //发送成功消息
        TipMessageView *tip = [[TipMessageView alloc] init];
        tip.headTitleText = @"Assign Bulb Channel";
        tip.tiptilteText = @"Success!";
        tip.tipDetailText = @"Your bulbs have been assigned.\nIf some bulbs did not respond,you may repeat this process.";
        tip.okButtonContent = @"Return";
        tip.isCancelIcon = NO;
        
        tip.okActionBlock = ^() {
            //返回 setting 界面
            [weakSelf returnViewController:[SettingViewController class]];
        };
        
        [tip show];
    }];
    
}

- (void)setBulbsCommand:(void (^)())onFinishedBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //
        NSDictionary *bulbDictionary = [self.bulbsArray objectAtIndex:self.bulbsSelectedIndex];
        BulbChannel *channel = [self.channelArray objectAtIndex:self.channelSelectedIndex];
        ChannelModel *model = [[ChannelModel alloc] initWithBulbChannel:channel];
        NSString *chanageIndex = [bulbDictionary objectForKey:@"value"];
        
        //发送设置命令
        if (channel) {
            [[BluetoothManager sharedInstance] sendData:[LightControllerCommand changeBulbChannel:model changedChannelIndex:[chanageIndex hexStringConvertIntValue]] onRespond:nil onTimeOut:nil];
            
//            [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand changeBulbChannel:model changedChannelIndex:[chanageIndex hexStringConvertIntValue]] withIdentifier:self.light.identifier];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onFinishedBlock)
                onFinishedBlock();
        });
    });
}

#pragma mark -DropdownListViewDelegate
- (void)didSelectedAction:(NSInteger)index
{
    //下拉菜单选择
    if (self.selectedType == BulbsSeleted) {
        //
        self.bulbsSelectedIndex = index;
        [self.tableView reloadData];
        
    } else if (self.selectedType == ChannelSeleted) {
        //
        self.channelSelectedIndex = index;
        [self.tableView reloadData];
    }
}

@end
