//
//  ManageWirelessPlugsViewController.m
//  VLCController
//
//  Created by mojingyu on 16/3/7.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ManageWirelessPlugsViewController.h"
#import "SettingViewController.h"
#import "UnpairWirelessPlugViewController.h"
#import "TextTableViewCell.h"

@interface ManageWirelessPlugsViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation ManageWirelessPlugsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Manage Wireless Switch";
    [self.tableView registerClass:[TextTableViewCell class] forCellReuseIdentifier:TextCellIdentifer];
    
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
    TextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TextCellIdentifer];
    cell.frame = (CGRect){0, 0, ScreenWidth, 60};
    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row == 0) {
        cell.titleText = @"Pair Wireless Switch";
    } else {
        cell.titleText = @"Unpair Wireless Switch";
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
        //Pair Wireless Plug
        [self checkPairWirelessPlug];
        
    } else {
        //Unpair Wireless Plug
        [self checkUnpairWirelessPlug];
    }
}

- (void)checkPairWirelessPlug
{
    [self showAlerViewWithMessage:@"Please unplug all other cords from this controller and plug in the wireless switch that you intend to pair. " onOKBlock:^{
        [self pairWirelessPlug];
    }];
    
//    TipMessageView *tip = [[TipMessageView alloc] init];
//    tip.headTitleText = @"Pair Wireless Plug";
//    tip.tiptilteText = nil;
//    tip.tipDetailText = @"Please connect in the wireless plug into an outlet.\n\nPlease make sure it's with 25ft. of this controller.";
//    tip.okButtonContent = @"Continue";
//    tip.cancelButtonContent = @"Cancel";
//    tip.isCancelIcon = YES;
//    
//    tip.okActionBlock = ^() {
//        [self pairWirelessPlug];
//    };
//    
//    [tip show];
}

- (void)pairWirelessPlug
{
    //调用接口
//    [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand pairWirelessPlug] withIdentifier:self.light.identifier];
    
    [MBProgressHUD showMessage:nil];
    
    __weak typeof(self) weakSelf = self;
    
    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand pairWirelessPlug:self.light.lightID] onRespond:^BOOL(NSData *data) {
        
        [MBProgressHUD hideHUD];
        
        //respond
        Byte value[30] = {0};
        [data getBytes:&value length:sizeof(value)];
        if (value[0] == 0xaa && value[1] == 0x0a) {
            
            TipMessageView *tip = [[TipMessageView alloc] init];
            tip.headTitleText = @"Pair Wireless Switch";
            tip.tiptilteText = @"Success!";
            tip.tipDetailText = @"Your wireless switch is paired.";
            tip.okButtonContent = @"Return";
            tip.isCancelIcon = YES;
            
            tip.okActionBlock = ^() {
                [weakSelf returnViewController:[SettingViewController class]];
            };
            
            [tip show];
            
            return YES;
        }
        else {            
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"data: %@", data] preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
//            [alertController addAction:okAction];
//            [weakSelf presentViewController:alertController animated:YES completion:nil];
            
            BLYLogError([NSString stringWithFormat:@"Paired Faild: %@", data]);
//            [MBProgressHUD showError:@"Paired Faild"];
            return NO;
        }
        
    } onTimeOut:^{
        
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"Your wireless switch could not be paired at this time.Please try again."];
        
    }];
    
}

- (void)checkUnpairWirelessPlug
{
    [self showAlerViewWithMessage:@"Please unplug all other cords from this controller and plug in the wireless switch that you intend to unpair. " onOKBlock:^{
        [self unpairWireless];
    }];
}

- (void)unpairWireless
{
    //    if (self.selectedIndex) {
    //        [MBProgressHUD showError:@"Please select a plug."];
    //        return;
    //    }
    
    //发送取消配对插头命令
    //    [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand unpairWirelessPlug] withIdentifier:self.light.identifier];
    
    [MBProgressHUD showMessage:nil];
    
    __weak typeof(self) weakSelf = self;
    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand unpairWirelessPlug:self.light.lightID] onRespond:^BOOL(NSData *data) {
        //respond
        [MBProgressHUD hideHUD];
        
        //respond
        Byte value[30] = {0};
        [data getBytes:&value length:sizeof(value)];
        if (value[0] == 0xaa && value[1] == 0x0a) {
            
            TipMessageView *tip = [[TipMessageView alloc] init];
            tip.headTitleText = @"Unpair Wireless Switch";
            tip.tiptilteText = @"Success!";
            tip.tipDetailText = @"Your wireless switch has been unpaired.";
            tip.okButtonContent = @"Return";
            tip.cancelButtonContent = nil;
            
            tip.okActionBlock = ^() {
                
                [weakSelf returnViewController:[SettingViewController class]];
            };
            
            [tip show];
            
            return YES;
        }
        else {
            BLYLogError([NSString stringWithFormat:@"Unpaired Faild: %@", data]);
//            [MBProgressHUD showError:@"UnPaired Faild."];
            return NO;
        }
        
    } onTimeOut:^{
        //time out
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"Your wireless switch could not be unpaired at this time.Please try again."];
    }];
    
    //
    
}

- (void)showAlerViewWithMessage:(NSString *)message onOKBlock:(void (^)())onOKBlock
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (onOKBlock) {
            onOKBlock();
        }
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
