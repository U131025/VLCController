//
//  BaseViewController.m
//  VLCController
//
//  Created by mojingyu on 16/1/7.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "BaseViewController.h"
#import "NSString+Extension.h"

@interface BaseViewController ()<UITableViewDataSource, UITableViewDelegate>
//@property (nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation BaseViewController

//@synthesize isRightButton = _isRightButton;
@synthesize isBackButton = _isBackButton;

- (id)init
{
    self = [super init];
    if (self) {
        self.isBackButton = YES;
        self.useDefaultTableView = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
    _backgroundImageView.frame = (CGRect){0, 0, ScreenWidth, ScreenHeight};
    [self.view addSubview:_backgroundImageView];
    [self.view sendSubviewToBack:_backgroundImageView];
    
    if (self.useDefaultTableView)
        [self setupTableViewWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, ScreenHeight-NavBarHeight-50)];
    
    if (_isBackButton)
        [self loadBackBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTableViewWithFrame:(CGRect)frame
{
    _tableView = [[UITableView alloc] initWithFrame:frame];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:DefaultCellIdentifier];
    [self.view addSubview:_tableView];
}

#pragma mark UITalbeViewDataSource 消除警告
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark 加载返回按钮
- (void)loadBackBtn
{
    // 添加返回按钮
    NSString *buttonText = @"＜Back";
    CGSize titleSize = [buttonText sizeWithFont:Font(14) maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, titleSize.width, titleSize.height)];
    btn.contentHorizontalAlignment = 1;
    btn.titleLabel.font = Font(14);
    [btn setTitle:buttonText forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
//    [btn setImage:[UIImage imageNamed:@"backArrow"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnBackClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    UIBarButtonItem *buttonItem=[[UIBarButtonItem alloc]initWithCustomView:btn];
    [self.navigationItem setLeftBarButtonItem:buttonItem animated:YES];
}

- (void)btnBackClicked:(UIButton *)sender
{
    self.tabBarController.tabBar.hidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 加载右边按钮
- (void)loadRightButton:(UIImage *)image title:(NSString *)title
{
    UIButton *btn;
    if (image) {
        btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [btn setImage:image forState:UIControlStateNormal];
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    if (title) {
        btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        //        btn.titleLabel.text = @"Done";
        btn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
        [btn.titleLabel setTextAlignment:NSTextAlignmentRight];
        
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
        //        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        
    }
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    [btn setTintColor:MainColor];
    [btn addTarget:self action:@selector(btnRightClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem=[[UIBarButtonItem alloc]initWithCustomView:btn];
    [self.navigationItem setRightBarButtonItem:buttonItem animated:YES];
}

- (void)btnRightClicked:(UIButton *)sender
{
}

//
- (void)startScanBluetooth
{
//    [[BluetoothManager sharedInstance] disConnectPeripheral];
    
    if (![[BluetoothManager sharedInstance] startScanBluetooth]) {
        //        __weak typeof(self) weakSelf = self;
        [MBProgressHUD hideHUD];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please open the Bluetooth on system settings." message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    };
}

- (void)returnViewController:(Class)returnVCClass
{
    for (UIViewController *viewcontroller in self.navigationController.viewControllers) {
        if ([viewcontroller isKindOfClass:returnVCClass]) {
            [self.navigationController popToViewController:viewcontroller animated:YES];
        }
    }
}

- (UIButton *)createDropDownButtonWithView:(UIView *)view withFrame:(CGRect)frame withTitle:(NSString *)title useArrow:(BOOL)useArrow
{
    CGFloat rowHeight = 60;
    myUILabel *topLabel = [[myUILabel alloc] initWithFrame:CGRectMake(50, CGRectGetMinY(frame), ScreenWidth-100, rowHeight)];
    topLabel.verticalAlignment = VerticalAlignmentBottom;
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.textColor = WhiteColor;
    topLabel.font = Font(15);
    topLabel.text = title;
    topLabel.numberOfLines = 0;
    [view addSubview:topLabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(topLabel.frame)+10, ScreenWidth-100, 60)];
    button.layer.borderColor = WhiteColor.CGColor;
    button.layer.borderWidth = 1;
    [button setTitleColor:WhiteColor forState:UIControlStateNormal];
    [view addSubview:button];
    
    if (useArrow) {
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button.frame)-40, CGRectGetMaxY(button.frame)-CGRectGetHeight(button.frame)/2 - 15, 30, 30)];
        arrowImageView.image = [UIImage imageNamed:@"downArrow"];
        [view addSubview:arrowImageView];
    }
    
    return button;
}

- (void)showTipWithMessage:(NSString *)message withTitle:(NSString *)title useCancel:(BOOL)useCancel onOKBlock:(void (^)())onOKBlock
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (onOKBlock) {
            onOKBlock();
        }
    }];
    
    if (useCancel) {
        [alertController addAction:cancleAction];
    }
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
