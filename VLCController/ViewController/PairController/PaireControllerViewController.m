//
//  PaireControllerViewController.m
//  VLCController
//
//  Created by Mojy on 2017/5/31.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "PaireControllerViewController.h"
#import "NSString+Extension.h"
#import "SetupResultViewController.h"
#import "ConnectModel.h"

@interface PaireControllerViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *idTextField;

@end

@implementation PaireControllerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Controller Set-Up";
    

    self.backgroundImageView.backgroundColor = RGBAlphaColor(57, 78, 126, 1);
    self.backgroundImageView.image = [UIImage imageNamed:@"TUTORIAL- 6 Manual Code Entry"];
    
    UIView *tipMessageView = [self creteaViewWithTitle:@"Controller ID" detail:@"type in the Controller ID\nfound under the QR Code."];
    [self.view addSubview:tipMessageView];
    [tipMessageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NavBarHeight + 50);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
    
    _idTextField = [[UITextField alloc] init];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 30)];
    _idTextField.leftView = leftView;
    _idTextField.textColor = WhiteColor;
    _idTextField.layer.borderColor = WhiteColor.CGColor;
    _idTextField.layer.borderWidth = 1;
    _idTextField.font = Font(15);
    _idTextField.textAlignment = NSTextAlignmentCenter;
    _idTextField.placeholder = @"Controller ID";
    _idTextField.delegate = self;
    [self.view addSubview:_idTextField];
    [_idTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(MarginValue);
        make.right.equalTo(self.view).offset(-MarginValue);
        make.top.equalTo(tipMessageView.mas_bottom).offset(30);
        make.height.mas_equalTo(ButtonHeight);
    }];
    
    UIButton *pairButton = [[UIButton alloc] init];
    pairButton.titleLabel.font = Font(15);
    pairButton.layer.borderWidth = 1;
    pairButton.layer.borderColor = WhiteColor.CGColor;
    [pairButton setTitle:@"Continue" forState:UIControlStateNormal];
    [pairButton setTitleColor:WhiteColor forState:UIControlStateNormal];
    [pairButton addTarget:self action:@selector(pairController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pairButton];
    [pairButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(MarginValue);
        make.right.equalTo(self.view).offset(-MarginValue);
        make.top.equalTo(_idTextField.mas_bottom).offset(20);
        make.height.mas_equalTo(ButtonHeight);
    }];
    
    UIButton *goBackButton = [[UIButton alloc] init];
    goBackButton.titleLabel.font = Font(13);
    [goBackButton setTitleColor:WhiteColor forState:UIControlStateNormal];
    [goBackButton setTitle:@"< Go Back" forState:UIControlStateNormal];
    [goBackButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goBackButton];
    [goBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pairButton.mas_bottom);
        make.centerX.equalTo(pairButton);
        make.width.height.equalTo(pairButton);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundClick:)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.view endEditing:YES];
}

- (void)backgroundClick:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

#pragma mark - Handle

- (void)pairController
{
    [self.view endEditing:YES];
    
#ifdef DEBUG
    if (self.idTextField.text.length == 0) {
        self.idTextField.text = @"Tv221u_qwe12345#888888";
    }
    
#endif
    
    if (self.idTextField.text.length == 0) {
        [MBProgressHUD showError:@"please input controller id."];
        return;
    }
    
    [self showHUDWithMessage:nil];
    
    //解析文本
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *string = self.idTextField.text;
        [self connectPeripheralWithMacAddrAndPasswordString:string];
    });
    
    
//    NSArray *deviceArray = [[BluetoothManager sharedInstance] device];
//    if (deviceArray.count == 0) {
//        
//        //重新扫描
//        [[BluetoothManager sharedInstance] startScanBluetooth];
//        
//        //2秒后遍历扫描设备并尝试连接
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self connectPeripheralWithMacAddrAndPasswordString:string];
//        });
//    }
//    else {
//        [self connectPeripheralWithMacAddrAndPasswordString:string];
//        
//    }
}

- (void)connectPeripheralWithMacAddrAndPasswordString:(NSString *)string
{
    __block ConnectModel *model = [[ConnectModel alloc] initWithString:string];
    if (!model) {
        [self hideHUD];
        [self showHUDWithMessage:@"Error Controller ID"];
        return;
    }
    
    [[BluetoothManager sharedInstance] connectWithName:model.deviceName oldPassword:model.password newPassword:model.password successBlock:^(CBPeripheral *peripheral, id data, BLERespondType type) {
        [self hideHUD];
        
        //连接蓝牙设备
        SetupResultType resultType = SetupResultTypeSuccess;
        SetupResultViewController *resultVC = [[SetupResultViewController alloc] initWithType:resultType];
        resultVC.peripheral = peripheral;
        resultVC.model = model;
        
        [self.navigationController pushViewController:resultVC animated:YES];
        
    } faileBlock:^(CBPeripheral *peripheral, id data, BLERespondType type) {
        
        [self hideHUD];
        //失败
        SetupResultType resultType = SetupResultTypeOops;
        SetupResultViewController *resultVC = [[SetupResultViewController alloc] initWithType:resultType];
        //        resultVC.model = model;
        
        [self.navigationController pushViewController:resultVC animated:YES];
    }];
    
//    [[BluetoothManager sharedInstance] connectPeriperalWithIndex:0 deviceName:model.deviceName oldPassword:model.password newPassword:model.password successBlock:^(CBPeripheral *peripheral, NSData *data, BLERespondType type) {
//        [self hideHUD];
//        
//        //连接蓝牙设备
//        SetupResultType resultType = SetupResultTypeSuccess;
//        SetupResultViewController *resultVC = [[SetupResultViewController alloc] initWithType:resultType];
//        resultVC.peripheral = peripheral;
//        resultVC.model = model;
//        
//        [self.navigationController pushViewController:resultVC animated:YES];
//        
//    } faileBlock:^(CBPeripheral *peripheral, NSData *data, BLERespondType type) {
//        [self hideHUD];
//        //失败
//        SetupResultType resultType = SetupResultTypeOops;
//        SetupResultViewController *resultVC = [[SetupResultViewController alloc] initWithType:resultType];
////        resultVC.model = model;
//        
//        [self.navigationController pushViewController:resultVC animated:YES];
//    }];
    
}

- (void)showHUDWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (message) {
            [MBProgressHUD showError:message toView:self.view];
        }
        else {
            [MBProgressHUD showMessage:message toView:self.view];
        }
    });
}

- (void)hideHUD
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

@end
