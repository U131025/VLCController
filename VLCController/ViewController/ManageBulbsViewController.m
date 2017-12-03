//
//  ManageBulbsViewController.m
//  VLCController
//
//  Created by mojingyu on 16/1/19.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ManageBulbsViewController.h"
#import "BulbChannelViewController.h"
#import "BulbChannel+Fetch.h"

@interface ManageBulbsViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation ManageBulbsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Manage Bulbs";
    [self.tableView registerClass:[TextTableViewCell class] forCellReuseIdentifier:@"TextTableViewCell"];
    
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

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"TextTableViewCell";
    TextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    cell.frame = (CGRect){0, 0, ScreenWidth, 60};
    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row == 0) {
        cell.titleText = @"Pair/UnPair";
    } else {
        cell.titleText = @"Change Bulb Channel";
    }
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(cell.frame)-1, ScreenWidth, 1)];
    line.backgroundColor = WhiteColor;
    [cell.contentView addSubview:line];
    
    cell.isArrow = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        //pair / unpair
        
        TipMessageView *tip = [[TipMessageView alloc] init];
        tip.headTitleText = @"Pair Bulbs";
        tip.tiptilteText = @"Warning!";
        tip.tipDetailText = @"All bulbs currently plugged into this controller will be paired to this controller only.\n\n Please make sure all bulbs are within 25ft. of this controller";
        tip.okButtonContent = @"Continue";
        tip.cancelButtonContent = @"Cancel";
        tip.isCancelIcon = YES;
        
        tip.okActionBlock = ^() {
            [self pairOrUnpairBulbs];
        };
        
        [tip show];
        
    } else {
        //Change bulb channel
        BulbChannelViewController *bulbChannelVC = [[BulbChannelViewController alloc] init];
        bulbChannelVC.light = self.light;
        [self.navigationController pushViewController:bulbChannelVC animated:YES];
    }
}

- (void)pairOrUnpairBulbs
{
    [MBProgressHUD showMessage:nil];
    
    [self pairOrUnpairBulbsAction:^{
        //
        [MBProgressHUD hideHUD];
        
        TipMessageView *tip = [[TipMessageView alloc] init];
        tip.headTitleText = @"Pair Bulbs";
        tip.tiptilteText = @"Success!";
        tip.tipDetailText = @"You bulbs have been paired.\nif some bulbs did not respond,you may repeat this process.";
        tip.okButtonContent = @"Return";
        tip.cancelButtonContent = nil;
        
        tip.okActionBlock = ^() {
            
            //
            [self.navigationController popViewControllerAnimated:YES];
        };
        [tip show];

    }];
    
}

- (void)pairOrUnpairBulbsAction:(void (^)())onFinishedBlock
{
    if (![[BluetoothManager sharedInstance] isConnectedPeripheral]) {
        [MBProgressHUD showError:@"Bluetooth device has been disconnected."];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //
//        NSMutableArray *channelArray = [[NSMutableArray alloc] init];
        NSArray *bulbChannelArray = [BulbChannel fetchWithLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
        
        if (bulbChannelArray.count == 0) {
            //添加默认的1~4个通道
            for (int index = 1; index < 5; index++) {
                
                NSString *channelName = [NSString stringWithFormat:@"Channel %d", index];
                BulbChannel *bulbChannel = [BulbChannel addWithName:channelName withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
                bulbChannel.index = [[NSNumber alloc] initWithInt:index];
                
//                [channelArray addObject:bulbChannel];
            }
        } else {
//            channelArray = [bulbChannelArray copy];
        }
        
//        BOOL isPair = ![self.light.isPairBulbs boolValue];
        
        //调用蓝牙接口 取消DB2命令，只发送DB1
        [[BluetoothManager sharedInstance] sendData:[LightControllerCommand pairOrUnpairBulbs:YES withTimeSp:self.light.lightID] onRespond:nil onTimeOut:nil];
        
//        if (![self.light.isPairBulbs boolValue]) {
//            //未配对
//            __weak typeof(self) weakSelf = self;
//
//#ifdef DEBUG
//            self.light.isPairBulbs = [[NSNumber alloc] initWithBool:YES];
//            [APPDELEGATE saveContext];
//#endif
//
//            [[BluetoothManager sharedInstance] sendData:[LightControllerCommand pairOrUnpairBulbs:YES withTimeSp:self.light.lightID] onRespond:^BOOL(NSData *data) {
//                //success
//                Byte value[30] = {0};
//                [data getBytes:&value length:sizeof(value)];
//                if (value[0] == 0xaa && value[1] == 0x0a) {
//                    weakSelf.light.isPairBulbs = [[NSNumber alloc] initWithBool:YES];
//                    [APPDELEGATE saveContext];
//                    return YES;
//                }
//                else {
//                    return NO;
//                }
//
//            } onTimeOut:nil];
//        }
//        else {
//            //已配对则取消配对
//            [[BluetoothManager sharedInstance] sendData:[LightControllerCommand pairOrUnpairBulbs:NO withTimeSp:self.light.lightID] onRespond:nil onTimeOut:nil];
//
//            self.light.isPairBulbs = [[NSNumber alloc] initWithBool:NO];
//            [APPDELEGATE saveContext];
////            [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand pairOrUnpairBulbs:isPair withTimeSp:self.light.lightID] withIdentifier:self.light.identifier];
//        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            if (onFinishedBlock)
                onFinishedBlock();
        });
        
    });
    
}

@end
