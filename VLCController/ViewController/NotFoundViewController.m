//
//  NotFoundViewController.m
//  VLCController
//
//  Created by mojingyu on 16/1/21.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "NotFoundViewController.h"
#import "NSString+Extension.h"
#import "FoundViewController.h"
#import "ColorOptionsViewController.h"
#import "ScanViewController.h"
#import "WkWebViewController.h"

@interface NotFoundViewController ()
@property (nonatomic, strong) NSString *tipDetailText;
@property (nonatomic, assign) BOOL processNotify;
@end

@implementation NotFoundViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.useDefaultTableView = NO;
        self.isBackButton = NO;
    }
    return self;
}

- (instancetype)initWithBackButton
{
    self = [super init];
    if (self) {
        self.useDefaultTableView = NO;
        self.isBackButton = YES;
    }
    return self;
}

- (NSString *)tipDetailText
{
    if (!_tipDetailText) {
        _tipDetailText = @"I don't see any controllers currently paired to this device.Plug in your controller and press Get Started below to get things set up";
    }
    return _tipDetailText;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _processNotify = NO;
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if ([BluetoothManager sharedInstance].device.count == 0) {
//        [[BluetoothManager sharedInstance] startScanBluetooth];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    self.navigationItem.title = @"Controller Set-Up";
    self.backgroundImageView.image = [UIImage imageNamed:@"TUTORIAL- 1. Intro"];
    
//    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
//    self.navigationItem.leftBarButtonItem = leftButton;
    
    UILabel *titleLalbel = [[UILabel alloc] init];
    titleLalbel.text= @"Welcome!";
    titleLalbel.textColor = [UIColor whiteColor];
    titleLalbel.textAlignment = NSTextAlignmentCenter;
    titleLalbel.font = Font(30);
    [self.view addSubview:titleLalbel];
    [titleLalbel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NavBarHeight + 50);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    
    UILabel *subTitleLabel = [[UILabel alloc] init];
    subTitleLabel.textAlignment = NSTextAlignmentCenter;
    subTitleLabel.textColor = [UIColor whiteColor];
    subTitleLabel.text = @"to Light Stream™";
    subTitleLabel.font = Font(30);
    [self.view addSubview:subTitleLabel];
    [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLalbel.mas_bottom);
        make.left.right.height.equalTo(titleLalbel);
    }];
    
    CGSize detailSize = [self.tipDetailText sizeWithFont:Font(14) maxSize:CGSizeMake(ScreenWidth-100, MAXFLOAT)];
    UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(50, CGRectGetMidY(self.view.frame)-detailSize.height-20, ScreenWidth-100, detailSize.height+10)];
    detailTextView.backgroundColor = [UIColor clearColor];
    detailTextView.text = self.tipDetailText;
    detailTextView.textAlignment = NSTextAlignmentCenter;
    detailTextView.font = Font(14);
    detailTextView.textColor = WhiteColor;
    detailTextView.userInteractionEnabled = NO;
    [self.view addSubview:detailTextView];
    [detailTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subTitleLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(ScreenWidth - 100);
        make.height.mas_equalTo(detailSize.height+10);
    }];
   
    UIButton *pairButton = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMidY(self.view.frame)+20, ScreenWidth-100, 50)];
    pairButton.backgroundColor = [UIColor whiteColor];
    [pairButton setTitleColor:BlueColor forState:UIControlStateNormal];
    [pairButton setTitle:@"GET STARTED" forState:UIControlStateNormal];
    [pairButton addTarget:self action:@selector(pairButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pairButton];
    [pairButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(detailTextView.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(ScreenWidth - 100);
        make.height.mas_equalTo(50);
    }];
    
    UIButton *websiteButton = [[UIButton alloc] init];
    websiteButton.titleLabel.font = Font(16);
    [websiteButton setTitle:@"View Tutorials" forState:UIControlStateNormal];
    [websiteButton addTarget:self action:@selector(viewTutorials) forControlEvents:UIControlEventTouchUpInside];
    [websiteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:websiteButton];
    [websiteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pairButton.mas_bottom).offset(10);
        make.left.right.equalTo(pairButton);
        make.height.mas_equalTo(30);
    }];
    
    //注册设备查找消息，及超时消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(discoverDeviceAction:) name:Notify_DiscoverDevice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanTimeOutAction:) name:Notify_ScanTimeOut object:nil];
}

//- (void)loadBackBtn
//{
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    btn.contentHorizontalAlignment = 1;
//    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//    UIBarButtonItem *buttonItem=[[UIBarButtonItem alloc]initWithCustomView:btn];
//    [self.navigationItem setLeftBarButtonItem:buttonItem animated:YES];
//}

- (void)discoverDeviceAction:(NSNotification *)notify
{
    if (_processNotify) {
        [MBProgressHUD hideHUD];
        MyLog(@"\n===============  goto FoundViewController 222 ==================\n ");
        _processNotify = NO;
        FoundViewController *foundVC = [[FoundViewController alloc] init];
        [self.navigationController pushViewController:foundVC animated:YES];
    }
    
}

- (void)scanTimeOutAction:(NSNotification *)notify
{
    [MBProgressHUD hideHUD];
    if (_processNotify) {
        //提示
        TipMessageView *tip = [[TipMessageView alloc] init];
        tip.headTitleText = @"Not Controller Found";
        tip.tiptilteText = @"Sorry,";
        tip.tipDetailText = @"I don't see any controllers currently paired to this device.Plug in your controller and press Get Started below to get things set up";
        tip.okButtonContent = @"Try Again";
        tip.cancelButtonContent = @"Cancel";
        [tip show];

        tip.okActionBlock = ^() {
            
            [self pairButtonClick];
        };
        
        tip.cancelActionBlock = ^() {
            NSLog(@"Cancel Action");
        };
        _processNotify = NO;
    }
    
}

- (void)tutorialButotnClick
{
    //导航
    
#ifdef TEST_CLOSE_BLUETOOTH
    ColorOptionsViewController *colorVC = [[ColorOptionsViewController alloc] init];
    [self.navigationController pushViewController:colorVC animated:YES];
#endif
}

- (void)pairButtonClick
{
    //获取二维码，mac地址，账号，密码
    ScanViewController *scanVC = [[ScanViewController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
    
    //扫描蓝牙外设
//    if (!_processNotify) {
//        [MBProgressHUD showMessage:nil];
//        
//        _processNotify = YES;
//        [self startScanBluetooth];
//    }
}

- (void)viewTutorials
{
//#warning 跳转到website
    WkWebViewController *webView = [[WkWebViewController alloc] initWithWebViewUrl:HomePageUrl titleName:@"Tutorials"];
    [self.navigationController pushViewController:webView animated:YES];
    
}


@end
