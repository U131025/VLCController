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

@interface NotFoundViewController ()
@property (nonatomic, strong) NSString *tipDetailText;
@property (nonatomic, assign) BOOL processNotify;
@end

@implementation NotFoundViewController

- (NSString *)tipDetailText
{
    if (!_tipDetailText) {
        _tipDetailText = @"No Controllers were found that are currently paired to this device.";
    }
    return _tipDetailText;
}

- (void)viewDidLoad {
    self.useDefaultTableView = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _processNotify = NO;
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    self.navigationItem.title = @"No Controller Found";
    
    CGSize detailSize = [self.tipDetailText sizeWithFont:Font(14) maxSize:CGSizeMake(ScreenWidth-100, MAXFLOAT)];
    UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(50, CGRectGetMidY(self.view.frame)-detailSize.height-20, ScreenWidth-100, detailSize.height+10)];
    detailTextView.backgroundColor = [UIColor clearColor];
    detailTextView.text = self.tipDetailText;
    detailTextView.textAlignment = NSTextAlignmentCenter;
    detailTextView.font = Font(14);
    detailTextView.textColor = WhiteColor;
    detailTextView.userInteractionEnabled = NO;
    [self.view addSubview:detailTextView];
    
    //button
//    UIButton *tutorialButton = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMidY(self.view.frame)+20, ScreenWidth-100, 50)];
//    tutorialButton.layer.borderColor = WhiteColor.CGColor;
//    tutorialButton.layer.borderWidth = 1;
//    [tutorialButton setTitle:@"Tutorial on Paring Controllers" forState:UIControlStateNormal];
//    [tutorialButton addTarget:self action:@selector(tutorialButotnClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:tutorialButton];
    
//    UIButton *pairButton = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(tutorialButton.frame)+20, CGRectGetWidth(tutorialButton.frame), CGRectGetHeight(tutorialButton.frame))];
    UIButton *pairButton = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMidY(self.view.frame)+20, ScreenWidth-100, 50)];
    pairButton.layer.borderWidth = 1;
    pairButton.layer.borderColor = WhiteColor.CGColor;
    [pairButton setTitle:@"Pair Controllers" forState:UIControlStateNormal];
    [pairButton addTarget:self action:@selector(pairButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pairButton];
    
    //注册设备查找消息，及超时消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(discoverDeviceAction:) name:Notify_DiscoverDevice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanTimeOutAction:) name:Notify_ScanTimeOut object:nil];
}

- (void)loadBackBtn
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    btn.contentHorizontalAlignment = 1;
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    UIBarButtonItem *buttonItem=[[UIBarButtonItem alloc]initWithCustomView:btn];
    [self.navigationItem setLeftBarButtonItem:buttonItem animated:YES];
}

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
        tip.tipDetailText = @"No controllers were found.\n\n Please make sure bluetooth is enalbed on this device,you're within 10ft.of the controllers and the controller is plugged in";
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
    //扫描蓝牙外设
    if (!_processNotify) {
        [MBProgressHUD showMessage:nil];
        
        _processNotify = YES;
        [self startScanBluetooth];
    }
}

@end
