//
//  SlaveControllerViewController.m
//  VLCController
//
//  Created by mojingyu on 16/3/10.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "SlaveControllerViewController.h"
#import "NSString+Extension.h"
#import "HomeViewController.h"

@interface SlaveControllerViewController()

@property (nonatomic, strong) NSString *tiptilteText;
@property (nonatomic, strong) NSString *tipDetailText;

@property (nonatomic, strong) NSString *okButtonContent;
@property (nonatomic, strong) UIButton *okButotn;

@end

@implementation SlaveControllerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Controller Settings";
    
    _tiptilteText = self.light.slave.name;
    _tipDetailText = [NSString stringWithFormat:@"This controllers settings are controlled by it's master \"%@\".\n\nTo change the settings,please goto the master controller settings.", self.light.name];
    _okButtonContent = @"Unlink";
    [self setupUI];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//
//}

- (void)setupUI
{
    //布局
    CGSize detailSize = [_tipDetailText sizeWithFont:Font(14) maxSize:CGSizeMake(ScreenWidth-100, MAXFLOAT)];
    UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(50, CGRectGetMidY(self.view.frame)-detailSize.height-20, ScreenWidth-100, detailSize.height+10)];
    detailTextView.backgroundColor = [UIColor clearColor];
    detailTextView.text = _tipDetailText;
    detailTextView.textAlignment = NSTextAlignmentCenter;
    detailTextView.font = Font(14);
    detailTextView.textColor = WhiteColor;
    detailTextView.userInteractionEnabled = NO;
    [self.view addSubview:detailTextView];
    
    //title
    UILabel *tipTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, CGRectGetMinY(detailTextView.frame)-50, ScreenWidth-100, 50)];
    tipTitleLabel.backgroundColor = [UIColor clearColor];
    tipTitleLabel.text = _tiptilteText;
    tipTitleLabel.textAlignment = NSTextAlignmentCenter;
    tipTitleLabel.font = Font(20);
    tipTitleLabel.textColor = WhiteColor;
    [self.view addSubview:tipTitleLabel];
    
    //button
    if (_okButtonContent) {
        _okButotn = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMidY(self.view.frame)+20, ScreenWidth-100, 50)];
        _okButotn.layer.borderColor = WhiteColor.CGColor;
        _okButotn.layer.borderWidth = 1;
        [_okButotn setTitle:_okButtonContent forState:UIControlStateNormal];
        [_okButotn addTarget:self action:@selector(unLink) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_okButotn];
    }
    
}

- (void)unLink
{
    TipMessageView *tip = [[TipMessageView alloc] init];
    tip.headTitleText = @"Unlink Controller";
    tip.tiptilteText = @"Are you sure?";
    tip.tipDetailText = @"This controller will no longer recieve settings from the master controller and will have to be updated manually.";
    tip.okButtonContent = @"Continue";
    tip.cancelButtonContent = @"Cancel";
    tip.isCancelIcon = YES;
    
    tip.okActionBlock = ^() {
        [self unLinkAction];
    };
    
    [tip show];
}

- (void)unLinkAction
{
    //发送蓝牙命令
//    [[BluetoothManager sharedInstance] sendDataToPeripheral:sendData withIdentifier:self.light.identifier];
    
    LightController *master = [LightController getObjectWithIdentifier:self.light.identifier inManagedObjectContext:APPDELEGATE.managedObjectContext];
    LightController *slave = [LightController getObjectWithIdentifier:self.light.slave.identifier inManagedObjectContext:APPDELEGATE.managedObjectContext];
    
    master.slave = nil;
    slave.master = nil;
    [APPDELEGATE saveContext];
    
    TipMessageView *tip = [[TipMessageView alloc] init];
    tip.headTitleText = @"Unlink Controller";
    tip.tiptilteText = @"Success!";
    tip.tipDetailText = @"This controller has been unlinked.\n\nYou may update the settings for this controller directly in the controller home screen.";
    tip.okButtonContent = @"Return";
    tip.cancelButtonContent = nil;
    
    tip.okActionBlock = ^() {
        
        [self returnViewController:[HomeViewController class]];
    };
    
    [tip show];
}


@end
