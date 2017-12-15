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
#import "NSData+Convert.h"

@interface BluetoothManager()<DeviceManagerDelegate>
{
    dispatch_semaphore_t _signal;
    dispatch_queue_t _queue;
}

//@property (nonatomic, strong) CBPeripheral *peripheral;
//@property (nonatomic, strong) BluetoothLibary *bluetoothClient;

@property (nonatomic, strong) NSData *resultData;

@property (nonatomic, copy) BluetoothCompleteBlock connectFailedBlock;
@property (nonatomic, copy) BluetoothCompleteBlock connectSuccessBlock;


//@property (nonatomic, getter=isRespond, assign) BOOL respond;

@property (nonatomic, copy) BOOL (^onRespondBlock)(NSData *respondData);
@property (nonatomic, copy) void (^OnRespondTimeoutBlock)();

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isNotify;
@property (nonatomic, assign) BOOL isFindDevice;

@end

@implementation BluetoothManager

//@synthesize respond = _respond;

//实现单例
SYNTHESIZE_SINGLETONE_FOR_CLASS(BluetoothManager);

- (instancetype)init
{
    self = [super init];
    if (self) {
        [DeviceManager sharedInstance].delegate = self;
        _signal = dispatch_semaphore_create(1);
        _queue = dispatch_queue_create("send queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)loadData
{
    self.timeOutSeconds = 8;
}

#pragma mark 蓝牙控制管理

- (void)connectWithName:(NSString *)name oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword successBlock:(BluetoothCompleteBlock)success faileBlock:(BluetoothCompleteBlock)failed
{
    [[DeviceManager sharedInstance] disconnectPeripheral];    
    
    self.isFindDevice = NO;
    self.connectSuccessBlock = success;
    self.connectFailedBlock = failed;
    
    [[DeviceManager sharedInstance] scanAndConnectPeripheralWithName:name oldPassword:oldPassword newPassword:newPassword];
    
    //超时设置
    if (failed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self timerClean];
            _timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(connectTimeout) userInfo:nil repeats:NO];
        });
    }
}

- (void)disconnectAllPeripheral
{
    [[DeviceManager sharedInstance] disconnectPeripheral];
}

- (void)sendData:(NSData *)sendData onRespond:(BOOL (^)(NSData *data))respond onTimeOut:(void (^)())timeOut
{
    [self sendData:sendData onRespond:respond timeOutValue:5 onTimeOut:timeOut];
}

- (void)sendData:(NSData *)sendData onRespond:(BOOL (^)(NSData *))respond timeOutValue:(NSInteger)timeOutValue onTimeOut:(void (^)())timeOut
{
    dispatch_async(_queue, ^{
       
//        dispatch_time_t duration = dispatch_time(DISPATCH_TIME_NOW, timeOutValue * NSEC_PER_SEC); //超时1秒
//        dispatch_semaphore_wait(_signal, duration);
        dispatch_semaphore_wait(_signal, DISPATCH_TIME_FOREVER);
        
        self.onRespondBlock = respond;
        self.OnRespondTimeoutBlock = timeOut;
        
        [[DeviceManager sharedInstance] sendDataToPeripheral:sendData];
        
        //超时设置
        if (timeOut) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self timerClean];
                _timer = [NSTimer scheduledTimerWithTimeInterval:timeOutValue target:self selector:@selector(runTimer) userInfo:nil repeats:NO];
            });
            
        }
        
#ifdef TEST_FILTER_RESPOND
        
        //模拟返回数据
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //
            static NSInteger index = 0;
            
            if (weakSelf.onRespondBlock) {
                
                [weakSelf timerClean];
                
                int pos = 0;
                Byte commandData[20] = {0};
                commandData[pos] = 0xaa; pos++;
                
                if (index == 1) {
                    commandData[pos] = 0xee; pos++;
                }
                else {
                    commandData[pos] = 0x0a; pos++;
                }
                
                //ID
                commandData[pos] = 0x00; pos++;
                
                Byte verify = [LightControllerCommand getVerify:commandData datalength:19];
                commandData[19] = verify;
                NSData *respondData = [[NSData alloc] initWithBytes:commandData length:20];
                
                if (weakSelf.onRespondBlock(respondData)) {
                    //返回结果处理
                    weakSelf.onRespondBlock = nil;
                    dispatch_semaphore_signal(_signal);
                }
            }
            else {
                 dispatch_semaphore_signal(_signal);
            }
            
            index++;
            
        });
        
#endif
        
    });
    
    
}

- (void)readDataWithRespond:(BOOL (^)(NSData *data))respond timeOutValue:(NSInteger)timeOutValue onTimeOut:(void (^)())timeOut
{
    self.onRespondBlock = respond;
    self.OnRespondTimeoutBlock = timeOut;
    
    [[DeviceManager sharedInstance] readData];
    
    //超时设置
    if (timeOut) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self timerClean];
            _timer = [NSTimer scheduledTimerWithTimeInterval:timeOutValue target:self selector:@selector(runTimer) userInfo:nil repeats:NO];
        });
        
    }
}

- (void)setBlockForDisconnected:(DisconnectedPeripheral)disconnectedBlock
{
    self.disconnectedBlock = disconnectedBlock;
}

#pragma mark - DeviceManagerDelegate
- (void)peripheralDiscovered:(CBPeripheral *)peripheral
{
    //发现设备
}

- (void)peripheralConnectedAtChannel:(NSString *)channel
{
#ifdef TEST_FILTER_RESPOND
    self.isFindDevice = YES;
    self.connectFailedBlock = nil;
    
    DeviceModel *model = [DeviceManager sharedInstance].model;
    if (self.connectSuccessBlock) {
        self.connectSuccessBlock(model.periperal, @"Success", BLERespondTypeSuccess);
        self.connectSuccessBlock = nil;
    }
    return;
#endif
}

- (void)peripheralDisconnectedAtChannel:(NSString *)channel
{
    //断开成功
    if (self.disconnectedBlock) {
        DeviceModel *model = [DeviceManager sharedInstance].model;
        self.disconnectedBlock(model.periperal);
    }
}

- (void)peripheralAtCharateristic:(CBCharacteristic *)charateristic notifyData:(NSData *)notifyData
{
    if (charateristic.value.length == 0) {
        return;
    }
    
    NSLog(@"==========\n notifyData: %@ \n==========\n", charateristic.value);
    
    if ([[charateristic.UUID UUIDString] isEqualToString:LIGHTBLUETOOTH_PAIR_NOTIFY_CHARACTERISTICS_UUID]) {
        
        DeviceModel *model = [DeviceManager sharedInstance].model;
        //校验配对结果
        const char *pData = [charateristic.value bytes];
        if (pData[0] == 0 || pData[0] == 0x30) {
            //success
            self.isFindDevice = YES;
            self.connectFailedBlock = nil;
            
            NSLog(@"\n ==== 配对成功 ===== \n");
            if (self.connectSuccessBlock) {
                self.connectSuccessBlock(model.periperal, charateristic.value, BLERespondTypeSuccess);
                self.connectSuccessBlock = nil;
            }            
            
            //成功后监听FFE4
            [[DeviceManager sharedInstance] listenNotify];
        }
        else if (pData[0] == 1) {
            
            self.isFindDevice = YES;
            if (self.connectFailedBlock) {
                [self disconnectAllPeripheral];
                self.connectFailedBlock(model.periperal, @"密码错误", BLERespondTypePairPWD);
                self.connectFailedBlock = nil;
            }
        }
        else {
            self.isFindDevice = YES;
            if (self.connectFailedBlock) {
                [self disconnectAllPeripheral];
                self.connectFailedBlock(model.periperal, @"密码错误", BLERespondTypePairPWD);
                self.connectFailedBlock = nil;
            }
        }
        [self timerClean];
    }
    
    if ([[charateristic.UUID UUIDString] isEqualToString:LIGHTBLUETOOTH_NOTIFY_CHARACTERISTICS_UUID]) {
        if (self.onRespondBlock) {
            
            if (self.onRespondBlock(notifyData)) {
                self.onRespondBlock = nil;
                self.OnRespondTimeoutBlock = nil;
                [self timerClean];
                
                dispatch_semaphore_signal(_signal);
            }
        }
        else {
            dispatch_semaphore_signal(_signal);
        }
    }
    
}

//超时设置
- (void)runTimer
{
    //timeOut
    self.onRespondBlock = nil;
    if (self.OnRespondTimeoutBlock) {
        self.OnRespondTimeoutBlock();
        self.OnRespondTimeoutBlock = nil;
        
        dispatch_semaphore_signal(_signal);
    }
    
    //退出超时判断
    [self timerClean];
}

- (void)connectTimeout
{
    if (!self.isFindDevice && self.connectFailedBlock) {
        [self disconnectAllPeripheral];
        
        if (self.connectFailedBlock) {
            self.connectFailedBlock(nil, @"没有匹配的设备", BLERespondTypeTimeout);
            self.connectFailedBlock = nil;
        }
    }
    [self timerClean];
}

- (void)timerClean
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - Getter
- (BOOL)isBluetoothOpen
{
    return [DeviceManager sharedInstance].bluetoothOpenStatue;
}

/**
 *  设备连接状态
 *
 *  @return YES 连接 NO 未连接
 */
- (BOOL)isConnectedPeripheral
{
#ifdef TEST_CLOSE_BLUETOOTH
    return YES;
#else

    DeviceModel *model = [DeviceManager sharedInstance].model;
    if (model.periperal.state == CBPeripheralStateConnected) {
        return YES;
    }
    else {
        return NO;
    }

#endif

}

- (NSArray *)device
{
    return [[DeviceManager sharedInstance].deviceSet allObjects];
}

- (CBPeripheral *)peripheral
{
    return [DeviceManager sharedInstance].model.periperal;
}



@end
