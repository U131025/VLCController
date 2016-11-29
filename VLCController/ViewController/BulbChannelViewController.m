//
//  BulbChannelViewController.m
//  VLCController
//
//  Created by mojingyu on 16/3/4.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "BulbChannelViewController.h"
#import "ChannelItemView.h"
#import "AssignBulbChannelViewController.h"
#import "SettingViewController.h"
#import "BulbChannel+Fetch.h"
#import "ManageBulbsViewController.h"

@interface BulbChannelViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *channelArray; //of BulbChannel
@end

@implementation BulbChannelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Change Bulb Channel";
    self.tableView.allowsSelection = NO;
    
    [self LoadDataFromDataBase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)channelArray
{
    if (!_channelArray) {
        _channelArray = [[NSMutableArray alloc] init];
    }
    
    return _channelArray;
}

- (void)LoadDataFromDataBase
{
//    [self.channelArray removeAllObjects];
    NSArray *bulbChannelArray = [BulbChannel fetchWithLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
    if (bulbChannelArray.count == 0) {
        //添加默认的1~4个通道
        for (int index = 1; index < 5; index++) {
            
            NSString *channelName = [NSString stringWithFormat:@"Channel %d", index];
            BulbChannel *bulbChannel = [BulbChannel addWithName:channelName withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
            bulbChannel.index = [[NSNumber alloc] initWithInt:index];
            
            [self.channelArray addObject:bulbChannel];
        }
    } else {
        self.channelArray = [bulbChannelArray copy];
    }
    [self.tableView reloadData];
}

#pragma mark -UITableViewDataSource
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
    if (indexPath.section == 0) {
        return 300;
    }
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
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
    
    if (indexPath.section == 0) {
        
        //
        CGFloat offsetX = 0;
        CGFloat offsetY = 10;
        CGFloat channelViewWidth = ScreenWidth / 2;
        CGFloat channelViewHeight = 40;
        BOOL useDeleteButton = NO;
        
        for (int index = 0; index < self.channelArray.count; index++) {
            
            if (index == 4) {
                offsetY = 10;
                offsetX += channelViewWidth+10;
                useDeleteButton = YES;
            }
            
            BulbChannel *channel = [self.channelArray objectAtIndex:index];
//            channel.index = index;
            ChannelItemView *itemView = [[ChannelItemView alloc] initWithFrame:CGRectMake(offsetX, offsetY, channelViewWidth, channelViewHeight) useDeleteButton:useDeleteButton];
            itemView.channel = [[ChannelModel alloc] initWithBulbChannel:channel];
            [cell.contentView addSubview:itemView];
            
            offsetY += channelViewHeight;
            
            itemView.onDeleteAction = ^(ChannelModel *ch) {
                
                [self deleteChannel:channel];
            };
            
        }
        
    } else if (indexPath.section == 1) {
        // Add button
        UIButton *addChannelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
        [cell.contentView addSubview:addChannelButton];
        
        addChannelButton.backgroundColor = RGBAlphaColor(255, 255, 255, 0.6);
        [addChannelButton setTitleColor:WhiteColor forState:UIControlStateNormal];
        
        [addChannelButton setTitle:@"Add New Channel+" forState:UIControlStateNormal];
        [addChannelButton addTarget:self action:@selector(addNewChannel:) forControlEvents:UIControlEventTouchUpInside];
        
    } else if (indexPath.section == 2) {
        //assign bulb
        UIButton *addChannelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
        [cell.contentView addSubview:addChannelButton];
        
        addChannelButton.backgroundColor = RGBAlphaColor(255, 255, 255, 0.6);
        [addChannelButton setTitleColor:WhiteColor forState:UIControlStateNormal];
        
        [addChannelButton setTitle:@"Change/Assign Bulb Channel+" forState:UIControlStateNormal];
        [addChannelButton addTarget:self action:@selector(assignBulbChannel:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark Button Action
- (void)addNewChannel:(UIButton *)button
{
    //add new bulb channel to database
    NSInteger count = self.channelArray.count;
    count++;
    if (count > 10) {
//        [MBProgressHUD showError:@"超出上限"];
        return;
    }
    
//    NSArray *bulbChannelArray = [BulbChannel fetchWithLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
    
    BOOL isAddObject = NO;
    NSInteger preIndex = -1;
    for (BulbChannel *bulbChannel in self.channelArray) {
        NSInteger index = [bulbChannel.index integerValue];        
        
        if (preIndex != -1 && ((preIndex + 1) < index)) {
            //缺少 preIndex + 1 这个通道
            NSInteger addIndex = preIndex+1;
            [self addNewChannelWithIndex:addIndex];
            isAddObject = YES;
            break;
        }
        preIndex = index;
    }
    
    if (!isAddObject) {
        NSInteger addIndex = preIndex+1;
        [self addNewChannelWithIndex:addIndex];
    }
    
    [self LoadDataFromDataBase];
    [self.tableView reloadData];
    
}

- (void)addNewChannelWithIndex:(NSInteger)addIndex
{
    NSString *channelName = [NSString stringWithFormat:@"Channel %ld", (long)addIndex];
    BulbChannel *newChannel = [BulbChannel addWithName:channelName withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
    newChannel.index = [[NSNumber alloc] initWithInteger:addIndex];
    
    [APPDELEGATE saveContext];
}

- (void)assignBulbChannel:(UIButton *)button
{
    // goto Assign Bulb Channel ViewController
    AssignBulbChannelViewController *assignVC = [[AssignBulbChannelViewController alloc] init];
    assignVC.channelArray = self.channelArray;
    assignVC.light = self.light;
    [self.navigationController pushViewController:assignVC animated:YES];
}

- (void)deleteChannel:(BulbChannel *)ch
{
    TipMessageView *tip = [[TipMessageView alloc] init];
    tip.headTitleText = @"Delete Channel";
    tip.tiptilteText = @"Are you sure?";
    tip.tipDetailText = [NSString stringWithFormat:@"You are about to delete \"%@\".", ch.name];
    tip.okButtonContent = @"Continue";
    tip.cancelButtonContent = @"Cancel";
    tip.isCancelIcon = YES;
    
    tip.okActionBlock = ^() {
        
        //返回 setting 界面
        [self deleteChannelAction:ch];
    };
    
    [tip show];
    
    
}

- (void)deleteChannelAction:(BulbChannel *)channel
{
    TipMessageView *tip = [[TipMessageView alloc] init];
    tip.headTitleText = @"Delete Channel";
    tip.tiptilteText = @"Success!";
    tip.tipDetailText = @"If you would like to re-assign bulbs to a new channel.use the change/assign bulb channel process inside the Manage Bulbs area of this application.";
    tip.okButtonContent = @"Return";
    tip.isCancelIcon = NO;
    
    tip.okActionBlock = ^() {
        
        //删除事件
        [BulbChannel removeObject:channel inManageObjectContext:APPDELEGATE.managedObjectContext];
        [APPDELEGATE saveContext];
        
        [self LoadDataFromDataBase];
//        [self returnViewController:[ManageBulbsViewController class]];
        
    };
    
    [tip show];
    
    
    

}


@end
