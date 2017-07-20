//
//  SetupResultViewController.m
//  VLCController
//
//  Created by Mojy on 2017/5/31.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "SetupResultViewController.h"
#import "NotFoundViewController.h"
#import "ConnectModel.h"

@interface SetupResultViewController ()<UITextFieldDelegate>

@property (nonatomic, assign) SetupResultType type;
@property (nonatomic, strong) UITextField *inputTextField;

@end

@implementation SetupResultViewController

- (instancetype)initWithType:(SetupResultType)type
{
    self = [super init];
    if (self) {
//        self.backgroundImageView.image = image;
        self.useDefaultTableView = NO;
        self.isBackButton = NO;
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Controller Set-Up";
    
    [self setupUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI
{
    if (self.type == SetupResultTypeSuccess) {
        [self createSuccessView];
    }
    else if (self.type == SetupResultTypeOops) {
        [self createOopsView];
    }
    else if (self.type == SetupResultTypeNiceToMeetYou) {
        [self createNiceToMeetYou];
    }
}

- (void)createNiceToMeetYou
{
    self.backgroundImageView.image = [UIImage imageNamed:@"TUTORIAL- 5. Name Controller"];
    
    UIView *tipView = [self creteaViewWithTitle:@"Nice to meet you." detail:@"What name would you like to give your controller?"];
    [self.view addSubview:tipView];
    [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NavBarHeight + 50);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
    
    _inputTextField = [[UITextField alloc] init];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 30)];
    _inputTextField.leftView = leftView;
    _inputTextField.textColor = WhiteColor;
    _inputTextField.layer.borderColor = WhiteColor.CGColor;
    _inputTextField.layer.borderWidth = 1;
    _inputTextField.font = Font(15);
    _inputTextField.textAlignment = NSTextAlignmentCenter;
    _inputTextField.placeholder = @"Example Controller Name";
    _inputTextField.delegate = self;
    [self.view addSubview:_inputTextField];
    [_inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(MarginValue);
        make.right.equalTo(self.view).offset(-MarginValue);
        make.top.equalTo(tipView.mas_bottom).offset(30);
        make.height.mas_equalTo(ButtonHeight);
    }];
    
    UIButton *continueButton = [[UIButton alloc] init];
    continueButton.titleLabel.font = Font(15);
    continueButton.layer.borderWidth = 1;
    continueButton.layer.borderColor = WhiteColor.CGColor;
    [continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    [continueButton setTitleColor:WhiteColor forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(continueAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
    [continueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(MarginValue);
        make.right.equalTo(self.view).offset(-MarginValue);
        make.top.equalTo(_inputTextField.mas_bottom).offset(20);
        make.height.mas_equalTo(ButtonHeight);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundClick:)];
    [self.view addGestureRecognizer:tap];
}

- (void)createOopsView
{
    self.backgroundImageView.image = [UIImage imageNamed:@"TUTORIAL- 3. Oops"];
    
    UIView *tipView = [self creteaViewWithTitle:@"Oops!" detail:@"Something went wrong,\nWould you like to try again?"];
    [self.view addSubview:tipView];
    [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NavBarHeight + 50);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
    
    UIButton *continueButton = [[UIButton alloc] init];
    continueButton.titleLabel.font = Font(15);
    continueButton.layer.borderWidth = 1;
    continueButton.layer.borderColor = WhiteColor.CGColor;
    [continueButton setTitle:@"Try Again" forState:UIControlStateNormal];
    [continueButton setTitleColor:WhiteColor forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(continueAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
    [continueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(MarginValue);
        make.right.equalTo(self.view).offset(-MarginValue);
        make.top.equalTo(tipView.mas_bottom).offset(20);
        make.height.mas_equalTo(ButtonHeight);
    }];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    cancelButton.layer.borderWidth = 1;
    cancelButton.layer.borderColor = WhiteColor.CGColor;
    cancelButton.titleLabel.font = Font(15);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(continueButton);
        make.top.equalTo(continueButton.mas_bottom).offset(10);
    }];
    
    UIButton *cancelIcon = [[UIButton alloc] init];
    [cancelIcon setTitle:@"✕" forState:UIControlStateNormal];
    cancelIcon.titleLabel.font = Font(30);
    [cancelIcon setTitleColor:WhiteColor forState:UIControlStateNormal];
    [cancelIcon addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelIcon];
    [cancelIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(cancelButton);
        make.width.mas_equalTo(60);
    }];
    
    UILabel *line = [[UILabel alloc] init];
    line.backgroundColor = WhiteColor;
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cancelIcon.mas_right);
        make.top.bottom.equalTo(cancelIcon);
        make.width.mas_equalTo(1);
    }];
    
    UILabel *tipLable = [[UILabel alloc] init];
    tipLable.text = @"If this happens again,you may want to\nrestart this app or your controller.";
    tipLable.textColor = WhiteColor;
    tipLable.numberOfLines = 0;
    tipLable.font = Font(13);
    tipLable.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLable];
    [tipLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cancelButton.mas_bottom).offset(10);
        make.left.right.equalTo(cancelButton);
        make.height.mas_equalTo(40);
    }];
    
}

- (void)createSuccessView
{
    self.backgroundImageView.image = [UIImage imageNamed:@"TUTORIAL- 4. Success"];
    
    UIView *tipView = [self creteaViewWithTitle:@"Success!" detail:@"Your controller has been paired to this device."];
    [self.view addSubview:tipView];
    [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NavBarHeight + 50);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
    
    UIButton *continueButton = [[UIButton alloc] init];
    continueButton.titleLabel.font = Font(15);
    continueButton.layer.borderWidth = 1;
    continueButton.layer.borderColor = WhiteColor.CGColor;
    [continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    [continueButton setTitleColor:WhiteColor forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(continueAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
    [continueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(MarginValue);
        make.right.equalTo(self.view).offset(-MarginValue);
        make.top.equalTo(tipView.mas_bottom).offset(20);
        make.height.mas_equalTo(ButtonHeight);
    }];
}



#pragma mark - Handle
- (void)continueAction
{
    if (self.type == SetupResultTypeOops) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (self.type == SetupResultTypeSuccess) {
        SetupResultViewController *viewController = [[SetupResultViewController alloc] initWithType:SetupResultTypeNiceToMeetYou];
        viewController.peripheral = self.peripheral;
        viewController.model = self.model;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if (self.type == SetupResultTypeNiceToMeetYou) {
        
        //配对当前
        [self showPairSuccess:self.peripheral];
    }
}

- (void)cancelAction
{
    
    
    
    if (self.type == SetupResultTypeOops) {
        //跳转回NotFoundViewController
        [self popToViewControllerClass:[NotFoundViewController class] animated:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.view endEditing:YES];
}

- (void)backgroundClick:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

#pragma mark - 配对操作
- (void)pairControllerAction
{
    //连接设备后发送配对指令
    NSLog(@"Pairing ...");
    
    if (self.peripheral) {
        
        //弹出配对密码输入框
        [self showInputView:^(NSString *password) {
            //
            CBPeripheral *peripheral = self.peripheral;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showMessage:nil];
            });
            
            [[BluetoothManager sharedInstance] connectWithName:@"" oldPassword:password newPassword:password successBlock:^(CBPeripheral *peripheral, id data, BLERespondType type) {
                
                [self showPairSuccess:peripheral];
                
            } faileBlock:^(CBPeripheral *peripheral, id data, BLERespondType type) {
                
                
            }];
            
            [[BluetoothManager sharedInstance] disconnectAllPeripheral];
            
//            [[BluetoothManager sharedInstance] pairDeviceWithOldPassword:password newPassWord:password withResponds:^(NSData *data) {
//                //
//                const char *pData = [data bytes];
//                
//                if (pData[0] == 0) {
//                    //success
//                    NSLog(@"\n ==== 配对成功 ===== \n");
//                    
//                    //success
//                    if (peripheral.state == CBPeripheralStateConnected) {
//                        
//                        [self showPairSuccess:peripheral];
//                    }
//                }
//                else if (pData[0] == 1) {
//                    //password error
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [MBProgressHUD hideHUD];
//                        [MBProgressHUD showError:@"Invalid password"];
//                    });
//                    
//                }
//                else if (pData[0] == 2) {
//                    //modify success
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [MBProgressHUD hideHUD];
//                    });
//                }
//                else if (pData[0] == 3) {
//                    //cancel password
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [MBProgressHUD hideHUD];
//                    });
//                }
//                
//            }];
//            
//            [[BluetoothManager sharedInstance] connectPeripheral:peripheral onSuccessBlock:^{
//                //success
//                
//            } onTimeoutBlock:^{
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [MBProgressHUD hideHUD];
//                });
//            }];
            
        } cancel:^{
            nil;
        }];
        
    }
}

- (void)showPairSuccess:(CBPeripheral *)peripheral
{
    //添加到数据库
    NSString *name;
    NSString *deviceName;
    if (self.inputTextField.text && ![self.inputTextField.text isEqualToString:@""]) {
        name = self.inputTextField.text;
    } else {
        name = deviceName;
    }
    
    NSString *identifier = [peripheral.identifier UUIDString];
    
    LightController *newObject = [LightController addObjectWithIdentifier:identifier inManagedObjectContext:APPDELEGATE.managedObjectContext];
    newObject.deviceName = deviceName;
    newObject.name = name;
    
    if (self.model) {
        newObject.password = self.model.password;
        newObject.macAddress = self.model.deviceName;
    }    
    
    [APPDELEGATE saveContext];
    
    //配对命令
    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand pairMainControllerCommand:newObject.lightID] onRespond:nil onTimeOut:nil];
    
//    [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand pairMainControllerCommand:newObject.lightID]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
    });
    
    //跳转到HomeViewController
    [self popToViewControllerClass:[HomeViewController class] animated:YES];

}

@end
