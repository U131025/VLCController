//
//  ScanViewController.m
//  VLCController
//
//  Created by Mojy on 2017/5/16.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+SDExtension.h"
#import "NSString+Extension.h"
#import "PaireControllerViewController.h"
#import "SetupResultViewController.h"
#import "ConnectModel.h"

static const CGFloat kBorderW = 100;
static const CGFloat kMargin = 80;

@interface ScanViewController ()<UIAlertViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, weak)   UIView *maskView;
@property (nonatomic, strong) UIView *scanWindow;
@property (nonatomic, strong) UIImageView *scanNetImageView;

@property (nonatomic, assign) BOOL isConnecting;

@end

@implementation ScanViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isConnecting = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hideHUD];
    
    if (_session && ![_session isRunning]) {
        self.isConnecting = NO;
        [_session startRunning];
        [self resumeAnimation];
    }
    
//    if ([BluetoothManager sharedInstance].device.count == 0) {
//        [[BluetoothManager sharedInstance] startScanBluetooth];
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_session && [_session isRunning]) {
        [_session stopRunning];
    }
    [self hideHUD];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI
{
    self.title = @"Controller Set-Up";
    self.view.clipsToBounds=YES;
    
    [self.backgroundImageView removeFromSuperview];
    
    //1.遮罩
    [self setupMaskView];
    //2.下边栏
    [self setupBottomBar];

    //5.扫描区域
    [self setupScanWindowView];
    
    //6.开始动画
    [self beginScanning];
    
    //扫描动画
    [self resumeAnimation];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resumeAnimation) name:@"EnterForeground" object:nil];
}

- (void)setupMaskView
{
    UIView *mask = [[UIView alloc] init];
    _maskView = mask;
    
    mask.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor;
//    mask.layer.borderWidth = kBorderW;

    mask.bounds = CGRectMake(0, 0, self.view.sd_width , self.view.sd_height/2.0);
    mask.center = CGPointMake(self.view.sd_width * 0.5, self.view.sd_height * 0.5);
    mask.sd_y = NavBarHeight;
    
    CGFloat scanWindowH = self.view.sd_width - kMargin * 2;
    UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:mask.bounds];
    [overlayPath setUsesEvenOddFillRule:YES];
    
    UIBezierPath *transparentRectPath = [UIBezierPath bezierPathWithRect:CGRectMake(kMargin, (mask.sd_height - scanWindowH) / 2, scanWindowH, scanWindowH)];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.frame = mask.bounds;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    
    [overlayPath appendPath:transparentRectPath];
    fillLayer.path = overlayPath.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    
    [_maskView.layer addSublayer:fillLayer];
    
    [self.view addSubview:mask];
   
}

- (void)setupBottomBar

{
    //1.下边栏
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.maskView.frame), self.view.sd_width, self.view.sd_height -  CGRectGetMaxY(self.maskView.frame))];
    bottomBar.backgroundColor = BlueColor;
//    bottomBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
//    bottomBar.backgroundColor = DefaultCellIdentifier
    
    [self.view addSubview:bottomBar];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mini logo"]];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [bottomBar addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(bottomBar).offset(-10);
        make.right.equalTo(bottomBar).offset(-10);
        make.width.height.mas_equalTo(30);
    }];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = @"Scan Me";
    tipLabel.font = Font(30);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor whiteColor];
    [bottomBar addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomBar).offset(20);
        make.left.right.equalTo(bottomBar);
        make.height.mas_equalTo(30);
    }];
    
    NSString *tipText = @"Scan QR code on the back of  your controller to begin pairing.";
    CGSize detailSize = [tipText sizeWithFont:Font(14) maxSize:CGSizeMake(ScreenWidth-100, MAXFLOAT)];
    
    UITextView *detailTextView = [[UITextView alloc] init];
    detailTextView.backgroundColor = [UIColor clearColor];
    detailTextView.text = tipText;
    detailTextView.textAlignment = NSTextAlignmentCenter;
    detailTextView.font = Font(14);
    detailTextView.textColor = WhiteColor;
    detailTextView.userInteractionEnabled = NO;
    [bottomBar addSubview:detailTextView];
    [detailTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipLabel.mas_bottom).offset(10);
        make.centerX.equalTo(bottomBar);
        make.width.mas_equalTo(ScreenWidth - 100);
        make.height.mas_equalTo(detailSize.height+10);
    }];
    
    UIButton *continueButton = [[UIButton alloc] init];
    continueButton.layer.borderColor = WhiteColor.CGColor;
    continueButton.layer.borderWidth = 1;
    continueButton.titleLabel.font = Font(15);
    [continueButton setTitle:@"Continue without scanning" forState:UIControlStateNormal];
    [continueButton setTitleColor:WhiteColor forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(continueWithoutScanning) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:continueButton];
    [continueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(detailTextView.mas_bottom).offset(10);
        make.centerX.equalTo(bottomBar);
        make.width.equalTo(detailTextView);
        make.height.mas_equalTo(ButtonHeight);
    }];
    
    UIButton *goBackButton = [[UIButton alloc] init];
    goBackButton.titleLabel.font = Font(13);
    [goBackButton setTitleColor:WhiteColor forState:UIControlStateNormal];
    [goBackButton setTitle:@"< Go Back" forState:UIControlStateNormal];
    [goBackButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:goBackButton];
    [goBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(continueButton.mas_bottom);
        make.centerX.equalTo(continueButton);
        make.width.height.equalTo(continueButton);
    }];
    
    //2.我的二维码
//    UIButton * myCodeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    myCodeBtn.frame = CGRectMake(0,0, self.view.sd_height * 0.1*35/49, self.view.sd_height * 0.1);
//    myCodeBtn.center=CGPointMake(self.view.sd_width/2, self.view.sd_height * 0.1/2);
//    [myCodeBtn setImage:[UIImage imageNamed:@"qrcode_scan_btn_myqrcode_down"] forState:UIControlStateNormal];
//    
//    myCodeBtn.contentMode=UIViewContentModeScaleAspectFit;
//    
//    [myCodeBtn addTarget:self action:@selector(myCode) forControlEvents:UIControlEventTouchUpInside];
//    [bottomBar addSubview:myCodeBtn];
    
    
}
- (void)setupScanWindowView
{
    CGFloat scanWindowH = self.view.sd_width - kMargin * 2;
    CGFloat scanWindowW = self.view.sd_width - kMargin * 2;
    _scanWindow = [[UIView alloc] initWithFrame:CGRectMake(kMargin, NavBarHeight + (self.maskView.sd_height - scanWindowH) / 2, scanWindowW, scanWindowH)];
    _scanWindow.clipsToBounds = YES;
    [self.view addSubview:_scanWindow];
    
    _scanNetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_net"]];
//    CGFloat buttonWH = 18;
    
    CALayer *layer = [CALayer layer];
    layer.borderColor = BlueColor.CGColor;
    layer.borderWidth = 2;
//    layer.frame = CGRectMake(0, 0, scanWindowW, scanWindowH);
    layer.frame = _scanWindow.bounds;
    [_scanWindow.layer addSublayer:layer];
    
//    UIButton *topLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWH, buttonWH)];
//    [topLeft setImage:[UIImage imageNamed:@"scan_1"] forState:UIControlStateNormal];
//    [_scanWindow addSubview:topLeft];
//    
//    UIButton *topRight = [[UIButton alloc] initWithFrame:CGRectMake(scanWindowW - buttonWH, 0, buttonWH, buttonWH)];
//    [topRight setImage:[UIImage imageNamed:@"scan_2"] forState:UIControlStateNormal];
//    [_scanWindow addSubview:topRight];
//    
//    UIButton *bottomLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, scanWindowH - buttonWH, buttonWH, buttonWH)];
//    [bottomLeft setImage:[UIImage imageNamed:@"scan_3"] forState:UIControlStateNormal];
//    [_scanWindow addSubview:bottomLeft];
//    
//    UIButton *bottomRight = [[UIButton alloc] initWithFrame:CGRectMake(topRight.sd_x, bottomLeft.sd_y, buttonWH, buttonWH)];
//    [bottomRight setImage:[UIImage imageNamed:@"scan_4"] forState:UIControlStateNormal];
//    [_scanWindow addSubview:bottomRight];
}

- (void)beginScanning
{
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input) return;
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置有效扫描区域
    CGRect scanCrop=[self getScanCrop:_scanWindow.bounds readerViewBounds:_maskView.frame];
    output.rectOfInterest = scanCrop;
    //初始化链接对象
    _session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [_session addInput:input];
    [_session addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];

    //开始捕获
    [_session startRunning];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count>0) {
//        [_session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:metadataObject.stringValue delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"再次扫描", nil];
//        [alert show];
        
//#warning 扫描结果处理
        NSString *stringValue = metadataObject.stringValue;
        if (stringValue.length > 0 && !self.isConnecting) {
            self.isConnecting = YES;
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];

            //解析mac地址
            [self connectPeripheralWithMacAddrAndPasswordString:stringValue];
        }
        
        [self resumeAnimation];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_session startRunning];
}

#pragma mark-> imagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //1.获取选择的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //2.初始化一个监测器
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        //监测到的结果数组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count >=1) {
            /**结果对象 */
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:scannedResult delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
        else{
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
        
//        [self beginScanning];
    }];
    
    
}
#pragma mark-> 闪光灯
-(void)openFlash:(UIButton*)button{
    
    NSLog(@"闪光灯");
    button.selected = !button.selected;
    if (button.selected) {
        [self turnTorchOn:YES];
    }
    else{
        [self turnTorchOn:NO];
    }
    
}

#pragma mark-> 开关闪光灯
- (void)turnTorchOn:(BOOL)on
{
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}


#pragma mark 恢复动画
- (void)resumeAnimation
{
    CAAnimation *anim = [_scanNetImageView.layer animationForKey:@"translationAnimation"];
    if(anim){
        // 1. 将动画的时间偏移量作为暂停时的时间点
        CFTimeInterval pauseTime = _scanNetImageView.layer.timeOffset;
        // 2. 根据媒体时间计算出准确的启动动画时间，对之前暂停动画的时间进行修正
        CFTimeInterval beginTime = CACurrentMediaTime() - pauseTime;
        
        // 3. 要把偏移时间清零
        [_scanNetImageView.layer setTimeOffset:0.0];
        // 4. 设置图层的开始动画时间
        [_scanNetImageView.layer setBeginTime:beginTime];
        
        [_scanNetImageView.layer setSpeed:1.0];
        
    }else{
        
        CGFloat scanNetImageViewH = 241;
        CGFloat scanWindowH = self.view.sd_width - kMargin * 2;
        CGFloat scanNetImageViewW = _scanWindow.sd_width;
        
        _scanNetImageView.frame = CGRectMake(0, -scanNetImageViewH, scanNetImageViewW, scanNetImageViewH);
        CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
        scanNetAnimation.keyPath = @"transform.translation.y";
        scanNetAnimation.byValue = @(scanWindowH);
        scanNetAnimation.duration = 1.0;
        scanNetAnimation.repeatCount = MAXFLOAT;
        [_scanNetImageView.layer addAnimation:scanNetAnimation forKey:@"translationAnimation"];
        [_scanWindow addSubview:_scanNetImageView];
    }
    
}
#pragma mark-> 获取扫描区域的比例关系
-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    
    CGFloat x,y,width,height;
    
    x = (CGRectGetHeight(readerViewBounds)-CGRectGetHeight(rect))/2/CGRectGetHeight(readerViewBounds);
    y = (CGRectGetWidth(readerViewBounds)-CGRectGetWidth(rect))/2/CGRectGetWidth(readerViewBounds);
    width = CGRectGetHeight(rect)/CGRectGetHeight(readerViewBounds);
    height = CGRectGetWidth(rect)/CGRectGetWidth(readerViewBounds);
    
    return CGRectMake(x, y, width, height);
    
}

#pragma mark - Handle

- (void)continueWithoutScanning
{
    PaireControllerViewController *pairVC = [[PaireControllerViewController alloc] init];
    [self.navigationController pushViewController:pairVC animated:YES];
    
}

- (void)pairControllerWithMacAddrAndPasswordString:(NSString *)string
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self connectPeripheralWithMacAddrAndPasswordString:string];
    
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
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        __block ConnectModel *model = [[ConnectModel alloc] initWithString:string];
        
        if (model) {
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
                
                if ([data isKindOfClass:[NSString class]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [MBProgressHUD showError:data];
                    });
                }
                
                //失败
                SetupResultType resultType = SetupResultTypeOops;
                SetupResultViewController *resultVC = [[SetupResultViewController alloc] initWithType:resultType];
                resultVC.model = model;
                
                [self.navigationController pushViewController:resultVC animated:YES];
                
            }];
        }
        else {
            [self hideHUD];
        }
    });
    
    
//    [[BluetoothManager sharedInstance] connectPeriperalWithIndex:0 deviceName:model.deviceName oldPassword:model.password newPassword:model.password successBlock:^(CBPeripheral *peripheral, NSData *data, BLERespondType type) {
//        
//        
//    } faileBlock:^(CBPeripheral *peripheral, id data, BLERespondType type) {
//        
//    }];
    
}

- (void)hideHUD
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

@end
