//
//  BluetoothLibary.m
//  BluetoothLibary
//
//  Created by JuLong on 15/6/17.
//  Copyright (c) 2015年 julong. All rights reserved.
//

#import "BluetoothLibary.h"

#define LIGHTBLUETOOTH_WRITE_SERVICE_UUID @"FFE5"
#define LIGHTBLUETOOTH_WRITE_CHARACTERISTICS_UUID @"FFE9"

#define LIGHTBLUETOOTH_NOTIFY_SERVICE_UUID @"FFE0"
#define LIGHTBLUETOOTH_NOTIFY_CHARACTERISTICS_UUID @"FFE4"

//#define LIGHTBLUETOOTH_WRITE_SERVICE_UUID @"FFF0"
//#define LIGHTBLUETOOTH_WRITE_CHARACTERISTICS_UUID @"FFF1"
//
//#define LIGHTBLUETOOTH_NOTIFY_SERVICE_UUID @"FFF1"
//#define LIGHTBLUETOOTH_NOTIFY_CHARACTERISTICS_UUID @"FFF1"

// NSLog 不打印
//#define NSLog(...) {}

@interface BluetoothLibary () <CBCentralManagerDelegate, CBPeripheralDelegate>


@property (nonatomic, strong) NSMutableArray *services; // of CBService

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *writeCharacteristics;

@property (nonatomic, strong) NSString *bluetoothMacAddress;    //匹配的蓝牙设备Mac地址
@property BOOL isAutoConnect;
@property BOOL cbReady;
@property BOOL isRefreshing;
@property BOOL foundDevice;

@property (nonatomic, copy) void (^onDisconnectedFinished)();
@end

@implementation BluetoothLibary

@synthesize delegate = _delegate;
@synthesize bluetoothMacAddress = _bluetoothMacAddress;
@synthesize devices = _devices;
@synthesize writeCharacteristics = _writeCharacteristics;

@synthesize peripheral = _peripheral;
@synthesize centralManager = _centralManager;

//@synthesize serviceUUID = _serviceUUID;
//@synthesize readUUID = _readUUID;
//@synthesize writeUUID = _writeUUID;
//@synthesize notifyUUID = _notifyUUID;

- (void)setDevices:(NSMutableArray *)devices
{
    _devices = devices;
}

- (NSMutableArray *)devices
{
    if (_devices == nil) {
        _devices = [[NSMutableArray alloc] init];
    }
    return _devices;
}

- (void)setCentralManager:(CBCentralManager *)centralManager
{
    _centralManager = centralManager;
}

- (CBCentralManager *)centralManager
{
    if (_centralManager == nil)
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    return _centralManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"init ...");
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    return self;
}


#pragma mark - 对外接口

//开始扫描蓝牙设备
- (void)startScan:(NSString *)scanDeviceMacAddress isReset:(BOOL)reset timeoutSeconds:(double)timeoutSeconds
{
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        
        [self.centralManager stopScan];
        NSLog(@"start scan ...");
        
        // 重置
        if (reset) {
            [self.devices removeAllObjects];
        }
        self.foundDevice = NO;
        
        // 扫描指定服务UUID 需要模块的服务UUID进行广播才有效
        [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:self.serviceUUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
        
        // 扫描全部
        
//        [self.centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
        
        
        // 超时设置
        if (timeoutSeconds > 0) {
            double delaySeconds = timeoutSeconds;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds *NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                
                [self.centralManager stopScan];
                NSLog(@"Time out, Stop scan.");
            });
        }
    }
}

// 根据UUID进行扫描
- (void)startScan:(NSString *)serviceUUID inReadUUID:(NSString *)readUUID inWriteUUID:(NSString *)writeUUID inTimeOutSeconds:(int)timeOutSeconds
{
    _serviceUUID = serviceUUID;
    _readUUID = readUUID;
    _writeUUID = writeUUID;
    _isAutoConnect = YES;
    [self startScan:nil isReset:YES timeoutSeconds:timeOutSeconds];
}

// 扫描所有设备
- (BOOL)startScanWithReset:(BOOL)reset withTimeOut:(NSInteger)seconds withTimeOutBlock:(void(^)())timeOutBlock
{
    
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //
            [self.centralManager stopScan];
            
            if (reset) {
                [self.devices removeAllObjects];
            }
            
            //扫描所有设备
            self.foundDevice = NO;
            if (self.serviceUUID) {
                [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:self.serviceUUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
            } else {
                [self.centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
            }
            
            //timeout
            if (seconds > 0) {
                double delaySeconds = seconds;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds *NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^{
                    
                    [self.centralManager stopScan];
                    if (timeOutBlock && !self.foundDevice) {
                        timeOutBlock();
                    }
                });
            }
            
        });
        
        return YES;
    }
   
    return NO;
}

//停止扫描
- (void)stopScan
{
    [self.centralManager stopScan];
    NSLog(@"stop scan.");
}

//手动连接蓝牙外设
- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    if (_cbReady && ![self.peripheral isEqual:peripheral]) {
        [self disConnectPeripheral];
    }
    
    NSLog(@"\n====================\n try connect peripheral: %@ \n====================\n", peripheral);
    if (_cbReady == NO) {
        [self stopScan];
        
        // connect device
        if (peripheral) {

            [self.centralManager connectPeripheral:peripheral options:@{ CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES }];
            
            if (peripheral.state == CBPeripheralStateConnected)
                _cbReady = YES;
        }
        
        NSLog(@"connectPeripheral: %@", peripheral);
    } else {
        //
        MyLog(@"设备已经连接.%@", self.peripheral);
    }
}

// 手动连接设备
- (void)connectPeripheral:(CBPeripheral *)peripheral withServiceUUID:(NSString *)serviceUUID withReadUUID:(NSString *)readUUID withWriteUUID:(NSString *)writeUUID
{
    _serviceUUID = serviceUUID;
    _readUUID = serviceUUID;
    _writeUUID = writeUUID;
    [self connectPeripheral:peripheral];
}

//断开连接
- (void)disConnectPeripheral
{
    [self cleanup];
}

- (void)disConnectPeripheral:(CBPeripheral *)peripheral onFinished:(void (^)())onFinished
{
    self.onDisconnectedFinished = onFinished;
    if ([peripheral isEqual:self.peripheral]) {
        [self cleanup];
    }
    else {
        [self cleanupPeripheral:peripheral];
    }
}

- (void)cleanupPeripheral:(CBPeripheral *)peripheral
{
    if (peripheral && peripheral.state == CBPeripheralStateConnected) {
        
        for (CBService *service in peripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    
                    if (!self.readUUID) {
                        self.readUUID = LIGHTBLUETOOTH_NOTIFY_CHARACTERISTICS_UUID;
                    }
                    
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:self.readUUID]]) {
                        if (characteristic.isNotifying) {
                            [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                    
                }
            }
        }
        
        NSLog(@"\n==========\n Diconnect peripheral : %@ \n=============\n", peripheral);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    else {
        NSLog(@"\n==========\n Diconnect peripheral Error: peripheral is %@ \n=============\n", peripheral);
        if (self.onDisconnectedFinished) {
            self.onDisconnectedFinished();
            self.onDisconnectedFinished = nil;
        }
    }
}

//关闭通知并断开连接
-(void)cleanup
{
    [self cleanupPeripheral:_peripheral];
    self.peripheral = nil;
    _cbReady = NO;
}

//发送数据至蓝牙设备
- (void)sendDataToPeripheral:(NSData *)sendData
{
#ifdef TEST_FILTER_NAME
    NSLog(@"send data: %@", sendData);
#endif
    
    if (self.peripheral != nil && _writeCharacteristics != nil) {
        
        MyLog(@"\n=============\n sendDataToPeripheral: %@ \n=============\n", sendData);
        [self.peripheral writeValue:sendData forCharacteristic:_writeCharacteristics type:CBCharacteristicWriteWithoutResponse];
    }
}

- (void)sendDataToPeripheral:(NSData *)sendData withResopnseType:(CBCharacteristicWriteType)type
{
    if (self.peripheral != nil && _writeCharacteristics != nil) {
        
        [self.peripheral writeValue:sendData forCharacteristic:_writeCharacteristics type:type];
    }
}

#pragma mark - CBCentralManagerDelegate

//查看服务，蓝牙开启
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"Bluetooth power on, please scan devices.");

            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"Bluetooth power off, please open it.");
            break;
        default:
            break;
    }
}

//找到外设后,添加至列表中
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //获取数据
//    NSData *manufacturerData = [advertisementData valueForKeyPath:CBAdvertisementDataManufacturerDataKey];
//    if (advertisementData.description.length > 0) {
//        NSLog(@"\n/======== advertisementData: %@ ==============/\n", advertisementData.description);
//        NSLog(@"\n/======== peripheral: %@ ===========/\n", peripheral.description);
//        NSLog(@"\n/======== identifer: %@ ============/\n", peripheral.identifier);
//    }
    
//    _peripheral = peripheral;
    
    // stop scan
    //[self.centralManager stopScan];
    
#ifndef TEST_FILTER_NAME
    //过滤其他设备
    NSString *deviceName = peripheral.name;
    if (!deviceName) return;
    deviceName = [deviceName lowercaseString];
    if (![deviceName hasPrefix:@"vlc"] && ![deviceName hasPrefix:@"tv"]) {
        return;
    }
#endif
    
    BOOL replace = NO;
    
    // Match if we have this device from before
    for (int i = 0; i < self.devices.count; i++) {
        CBPeripheral *peripheralObject = [self.devices objectAtIndex:i];
        if ([peripheralObject isEqual:peripheral]) {
            [self.devices replaceObjectAtIndex:i withObject:peripheral];
            replace = YES;
        }
    }
    
//#ifdef TEST_FILTER_NAME
    MyLog(@"Discover Peripheral:%@ identifier:%@ at %@", peripheral, peripheral.identifier, RSSI);
//#endif
    
    if (!replace) {
        
        [self.devices addObject:peripheral];
        
        if (_isAutoConnect) {
            [self connectPeripheral:peripheral];
        }
        
        MyLog(@"\n=================\n Discover Peripheral:%@ identifier:%@ at %@", peripheral, peripheral.identifier, RSSI);
        
        if ([self.delegate respondsToSelector:@selector(didDiscoverPeripheral:)]) {
            [self.delegate didDiscoverPeripheral:peripheral];
        }
        
    }
}

//连接外设成功，开始发现服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"connect success %@", peripheral);
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    
    //连接成功通知 发现服务后发送成功消息，否则发送不出数据
//    if ([self.delegate respondsToSelector:@selector(connetctSuccess:)]) {
//        [self.delegate connetctSuccess:peripheral];
//    }
}

//连接断开
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"\n======  Disconnect error: %@ ========\n", [error localizedDescription]);
    NSLog(@"\n======  Disconnect peripheral: %@ ========\n", peripheral);
    _cbReady = NO;
    
    if (self.onDisconnectedFinished) {
        self.onDisconnectedFinished();
        self.onDisconnectedFinished = nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(didDisconnectPeripheral)]) {
        [self.delegate didDisconnectPeripheral];
    }
}

//连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"===== didFailToConnectPeripheral error: %@", [error localizedDescription]);
    if (_isAutoConnect) {
        [self startScan:nil isReset:YES timeoutSeconds:0];
    }
}

//发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        NSLog(@"Discover services: %@, UUID: %@", service, service.UUID);
        [self.services addObject:service];
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:LIGHTBLUETOOTH_WRITE_SERVICE_UUID]]) {
            //写服务
            [peripheral discoverCharacteristics:nil forService:service];
            
        } else if ([service.UUID isEqual:[CBUUID UUIDWithString:LIGHTBLUETOOTH_NOTIFY_SERVICE_UUID]]) {
            //通知
            [peripheral discoverCharacteristics:nil forService:service];
            
        } else {
            //测试
#ifdef TEST_FILTER_NAME
           [peripheral discoverCharacteristics:nil forService:service];
#endif
        }
        
    }
}

//已搜索到得Characteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"discover characteristics error:%@", [error localizedDescription]);
        [self cleanup];
        return;
    }
        
    for (CBCharacteristic *characteristics in service.characteristics) {
        
        NSLog(@"\n=============\n Characteristics UUID: %@ (%@)", characteristics.UUID.data, characteristics.UUID);
        
        if ([characteristics.UUID isEqual:[CBUUID UUIDWithString:LIGHTBLUETOOTH_WRITE_CHARACTERISTICS_UUID]]) {
            _writeCharacteristics = characteristics;
            
            //连接成功通知
            if ([self.delegate respondsToSelector:@selector(connetctSuccess:)]) {
                [self.delegate connetctSuccess:peripheral];
            }

        }
        
        if ([characteristics.UUID isEqual:[CBUUID UUIDWithString:LIGHTBLUETOOTH_NOTIFY_CHARACTERISTICS_UUID]]) {
            
            [self.peripheral readValueForCharacteristic:characteristics];
            [self.peripheral setNotifyValue:YES forCharacteristic:characteristics];
        }
        
        // other characteristics
        
    }
    
    self.peripheral = peripheral;
    
#ifdef TEST_FILTER_NAME
    //连接成功通知 因为有2个服务需要扫描，这里会触发2次连接成功的通知
    if ([self.delegate respondsToSelector:@selector(connetctSuccess:)]) {
        [self.delegate connetctSuccess:peripheral];
    }
    
#endif
    

}

//获取外设发送的数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error updating value for charateristic %@ error :%@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:LIGHTBLUETOOTH_NOTIFY_CHARACTERISTICS_UUID]]) {
        
        if (characteristic.value.length > 0) {
            
            NSLog(@"readData: %@", characteristic.value);
            if ([self.delegate respondsToSelector:@selector(updateValueForPeripheral:)]) {
                [self.delegate updateValueForPeripheral:characteristic.value];
                
            }
        }
        
    }
    // other peripheral data
    
}

//中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", [error localizedDescription]);
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
    } else {
        NSLog(@"cancelPeripheralConnection: ");
        // Notification has stopped, so disconnect from the peripheral
        [self.centralManager cancelPeripheralConnection:peripheral];
        
    }
}

//用于检测中心向外设写数据是否成功
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Write Error: %@", error.userInfo);
    } else {
       NSLog(@"Write Success.");
    }
}

@end
