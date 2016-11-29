//
//  BluetoothManager.m
//  VLCController
//
//  Created by mojingyu on 16/1/21.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "BluetoothManager.h"
#import "LightController+Fetch.h"
#import "LightControllerCommand.h"

@interface BluetoothManager()<BluetoothLibaryDelegate>

//@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) BluetoothLibary *bluetoothClient;
@property (nonatomic, strong) NSData *resultData;
@property (nonatomic, copy) void (^onConnectSuccessBlock)();
@property (nonatomic, copy) void (^onConnectTimeoutBlock)();
@property (nonatomic, getter=isRespond, assign) BOOL respond;

@property (nonatomic, copy) BOOL (^onRespondBlock)(NSData *respondData);
@property (nonatomic, copy) void (^onTimeOutBlock)();
@property (nonatomic, copy) void (^onDisConnectedFinished)();

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation BluetoothManager

@synthesize respond = _respond;

//实现单例
SYNTHESIZE_SINGLETONE_FOR_CLASS(BluetoothManager);

- (void)loadData
{
    self.timeOutSeconds = 8;
}

#pragma mark 蓝牙控制管理
- (NSMutableArray *)device
{
    return self.bluetoothClient.devices;
}

- (LightControllerModel *)getLightControllerModelFromDevice:(NSString *)name
{
    LightControllerModel *finder = nil;
    for (LightControllerModel *light in self.device) {
        if ([light.name isEqualToString:name]) {
            finder = light;
            break;
        }
    }
    return finder;
}

- (CBPeripheral *)getPeripheralWithIdentifier:(NSString *)identifier
{
    for (CBPeripheral *peripheral in self.device) {
        NSString *curIdentifier = [peripheral.identifier UUIDString];        
        if ([curIdentifier isEqualToString:identifier]) {
            return peripheral;
        }
    }
    return nil;
}

- (BluetoothLibary *)bluetoothClient
{
    if (!_bluetoothClient) {
        _bluetoothClient = [[BluetoothLibary alloc] init];
        _bluetoothClient.delegate = self;
    }
    return _bluetoothClient;
}


- (BOOL)startScanBluetooth
{
    BOOL retCode = [self.bluetoothClient startScanWithReset:YES withTimeOut:5.0 withTimeOutBlock:^{
        //通知超时
        [[NSNotificationCenter defaultCenter] postNotificationName:Notify_ScanTimeOut object:nil];
//        if (self.onConnectTimeoutBlock) {
//            self.onConnectTimeoutBlock();
//        }
    }];
        
    return retCode;    
}

- (BOOL)connectPeripheral:(CBPeripheral *)peripheral onSuccessBlock:(void (^)())onSuccessBlock onTimeoutBlock:(void (^)())onTimeoutBlock
{
    if (!peripheral) return NO;    
    
    self.onConnectSuccessBlock = onSuccessBlock;
    self.onConnectTimeoutBlock = onTimeoutBlock;
    [self.bluetoothClient connectPeripheral:peripheral];
    
    double delaySeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds *NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{

        if (self.onConnectTimeoutBlock) {
            self.onConnectTimeoutBlock();
            self.onConnectSuccessBlock = nil;
        }
    });
    
    return YES;
}

// 发送数据至蓝牙设备
- (void)sendDataToPeripheral:(NSData *)sendData
{
    if (!_peripheral || _peripheral.state != CBPeripheralStateConnected) {
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD showError:@"Bluetooth device has been disconnected."];
//        });
        NSLog(@"Bluetooth device has been disconnected.");
       
    }
    else {
       [self.bluetoothClient sendDataToPeripheral:sendData];
    }
    
}

- (void)sendDataToPeripheral:(NSData *)sendData withIdentifier:(NSString *)identifier
{  
    CBPeripheral *peripheral = [self getPeripheralWithIdentifier:identifier];
    
    if (peripheral.state != CBPeripheralStateConnected) {
        //尝试进行连接
        [self connectPeripheral:peripheral onSuccessBlock:^{
            [self sendDataToPeripheral:sendData];
        } onTimeoutBlock:^{
//            [MBProgressHUD showError:@"Bluetooth device has been disconnected."];
        }];
    }
    else {
        [self sendDataToPeripheral:sendData];
    }
}

- (void)sendData:(NSData *)sendData withIdentifier:(NSString *)identifier onRespond:(BOOL (^)(NSData *data))respond onTimeOut:(void (^)())timeOut
{
    CBPeripheral *peripheral = [self getPeripheralWithIdentifier:identifier];
    if (peripheral.state != CBPeripheralStateConnected) {
//        [self connectPeripheral:peripheral onSuccessBlock:nil onTimeoutBlock:nil];
        
        [self connectPeripheral:peripheral onSuccessBlock:^{
            [self sendData:sendData onRespond:respond onTimeOut:timeOut];
        } onTimeoutBlock:^{
//            [MBProgressHUD showError:@"Bluetooth device has been disconnected."];
        }];
    }
    else if (peripheral) {
        [self sendData:sendData onRespond:respond onTimeOut:timeOut];
    }
}

- (void)sendData:(NSData *)sendData onRespond:(BOOL (^)(NSData *))respond onTimeOut:(void (^)())timeOut
{
    self.respond = YES;
    self.onRespondBlock = respond;
    self.onTimeOutBlock = timeOut;
    [self sendDataToPeripheral:sendData];
    
    //如果有定时器则先取消再创建
    [self timerClean];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:self.timeOutSeconds target:self selector:@selector(runTimer) userInfo:nil repeats:NO];
    
#ifdef TEST_FILTER_RESPOND
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //
        if (weakSelf.isRespond) {
            
            weakSelf.respond = NO;
            [weakSelf timerClean];
            
            if (weakSelf.onRespondBlock) {
                
                int pos = 0;
                Byte commandData[20] = {0};
                commandData[pos] = 0xaa; pos++;
                commandData[pos] = 0xee; pos++;
                //ID
                commandData[pos] = 0x00; pos++;
                
                Byte verify = [LightControllerCommand getVerify:commandData datalength:19];
                commandData[19] = verify;
                NSData *respondData = [[NSData alloc] initWithBytes:commandData length:20];
                
                if (weakSelf.onRespondBlock(respondData)) {
                    //返回结果处理
                }
            }
        }
        
    });
    
#endif
    
}

- (void)runTimer
{
    //timeOut
    if (self.respond) {
        
        self.respond = NO;
        
        if (self.onTimeOutBlock) {
            self.onTimeOutBlock();
        }
        
        if ([self.delegate respondsToSelector:@selector(receiveTimeOut:)]) {
            [self.delegate receiveTimeOut:self.peripheral];
        }
    }
    
    //退出超时判断
    [self timerClean];
}

- (void)timerClean
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}


#pragma mark BluetoothLibaryDelegate
- (void)reciveMacAddressData:(NSData *)data
{
    //mac 地址
}

- (void)updateValueForPeripheral:(NSData *)data
{
    // 接收数据并进行解析    
    if (self.isRespond) {
        
        if (self.onRespondBlock) {
            
            if (self.onRespondBlock(data)) {
                self.respond = NO;
                [self timerClean];
            }
        }
        
        //处理返回数据
        if ([self.delegate respondsToSelector:@selector(receiveSuccess:)]) {
            [self.delegate receiveSuccess:data];
        }        
    }
    
}

- (void)didDiscoverPeripheral:(CBPeripheral *)peripheral
{
    NSString *deviceName = peripheral.name;
    if (!deviceName) return;
    deviceName = [deviceName lowercaseString];
    
    //前缀是否包含 vlc 或 tv 开头的设备
#ifdef TEST_FILTER_NAME
    NSMutableDictionary *userinfoDic = [[NSMutableDictionary alloc] init];
    [userinfoDic setObject:peripheral forKey:@"CBPeripheral"];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notify_DiscoverDevice object:nil userInfo:userinfoDic];
#else
    if ([deviceName hasPrefix:@"vlc"] || [deviceName hasPrefix:@"tv"]) {
        NSMutableDictionary *userinfoDic = [[NSMutableDictionary alloc] init];
        [userinfoDic setObject:_peripheral forKey:@"CBPeripheral"];
        [[NSNotificationCenter defaultCenter] postNotificationName:Notify_DiscoverDevice object:nil userInfo:userinfoDic];
    }
#endif    
    
}

- (void)didDisconnectPeripheral
{
    
    [self.bluetoothClient disConnectPeripheral];
    _peripheral = nil;
    
    if (self.onDisConnectedFinished) {
        self.onDisConnectedFinished();
        self.onDisConnectedFinished = nil;
    }
    
    //通知连接断开
    [[NSNotificationCenter defaultCenter] postNotificationName:Notify_Disconnect object:nil];
}

- (void)disConnectPeripheral
{
    [self.bluetoothClient disConnectPeripheral];
}

- (void)disConnectPeripheral:(void (^)())onFinished
{
    self.onDisConnectedFinished = onFinished;
    [self didDisconnectPeripheral];
}

- (void)disConnectPeripheral:(CBPeripheral *)periphseral onFinished:(void (^)())onFinished
{
//    self.onDisConnectedFinished = onFinished;
    [self.bluetoothClient disConnectPeripheral:periphseral onFinished:onFinished];
}

- (void)connetctSuccess:(CBPeripheral *)peripheral
{
    if (peripheral.state == CBPeripheralStateConnected) {
        //连接成功，通知
        _peripheral = peripheral;
        
        self.onConnectTimeoutBlock = nil;
        
        if (self.onConnectSuccessBlock) {
            self.onConnectSuccessBlock();
            
            //连接上后清空
            self.onConnectSuccessBlock = nil;
        }
    }
    
}

//根据identifier搜索设备
- (void)scanBluetoothWithIdentifier:(NSString *)identifier onSuccessBlock:(void (^)())onSuccessBlock onTimeoutBlock:(void (^)())onTimeoutBlock
{
    //
}
/**
 *  设备连接状态
 *
 *  @return YES 连接 NO 未连接
 */
- (BOOL)isConnectedPeripheral
{
    if (self.peripheral.state == CBPeripheralStateConnected) {
        return YES;
    }
    else {
      
//        [self connectPeripheral:self.peripheral onSuccessBlock:^{
//
//        } onTimeoutBlock:^{
//
//        }];
        
        return NO;
    }
    
}

@end
