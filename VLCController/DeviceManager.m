//
//  DeviceManager.m
//  zhenjiu
//
//  Created by mojingyu on 2017/4/3.
//  Copyright © 2017年 com.huang. All rights reserved.
//

#import "DeviceManager.h"
#import "BabyBluetooth.h"

@interface DeviceManager ()

@property (nonatomic, strong) BabyBluetooth *baby;
@property (nonatomic, strong) NSHashTable *delegateHashTable;

@property (nonatomic, strong) NSString *passwordOld;
@property (nonatomic, strong) NSString *passwordNew;

@end

@implementation DeviceManager

+ (instancetype)sharedInstance
{
    static DeviceManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DeviceManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupBabyDelegate];
    }
    return self;
}

- (NSMutableDictionary *)peripheralDic
{
    if (!_peripheralDic) {
        _peripheralDic = [[NSMutableDictionary alloc] init];
    }
    return _peripheralDic;
}

- (NSHashTable *)delegateHashTable
{
    if (!_delegateHashTable) {
        _delegateHashTable = [NSHashTable weakObjectsHashTable];
    }
    return _delegateHashTable;
}

- (NSMutableSet *)deviceSet
{
    if (!_deviceSet) {
        _deviceSet = [[NSMutableSet alloc] init];
    }
    return _deviceSet;
}

- (DeviceModel *)getModelAtChannel:(NSString *)channel
{
    DeviceModel *model = [self.peripheralDic objectForKey:channel];
    if (!model) {
        model = [[DeviceModel alloc] init];
        [self.peripheralDic setObject:model forKey:channel];
    }
    
    return model;
}

- (DeviceModel *)model
{
    return [self getModelAtChannel:ChannelOne];
}

- (BOOL)bluetoothOpenStatue
{
    if (self.baby.centralManager.state == CBCentralManagerStatePoweredOn) {
        return YES;
    }
    
    return NO;
}

- (void)setDelegate:(id<DeviceManagerDelegate>)delegate
{
    [self.delegateHashTable addObject:delegate];
}

- (void)setupBabyDelegate
{
    self.baby = [BabyBluetooth shareBabyBluetooth];
    //设置扫描到设备的委托
    __weak typeof(self) weakSelf = self;
    [self.baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        if (![weakSelf.deviceSet containsObject:peripheral]) {
            
            NSLog(@"搜索到了设备:%@",peripheral.name);
            [weakSelf.deviceSet addObject:peripheral];
            
            for (id<DeviceManagerDelegate> delegate in weakSelf.delegateHashTable) {
                if ([delegate respondsToSelector:@selector(peripheralDiscovered:)]) {
                    [delegate peripheralDiscovered:peripheral];
                }
            }
        }
        
    }];
    
    [self setBabyDelegateAtChannel:ChannelOne];
//    [self setBabyDelegateAtChannel:ChannelTwo];
//    [self setBabyDelegateAtChannel:ChannelThree];
//    [self setBabyDelegateAtChannel:ChannelFour];
    
}

- (void)setBabyDelegateAtChannel:(NSString *)channel
{
    __weak typeof(self) weakSelf = self;
    //设置设备连接成功的委托
    [self.baby setBlockOnConnectedAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        //
        NSLog(@"设备：%@--连接成功",peripheral.name);
        DeviceModel *model = [weakSelf getModelAtChannel:channel];
        model.periperal = peripheral;
        model.deviceName = channel;
        
        for (id<DeviceManagerDelegate> delegate in weakSelf.delegateHashTable) {
            if ([delegate respondsToSelector:@selector(peripheralConnectedAtChannel:)]) {
                [delegate peripheralConnectedAtChannel:channel];
            }
        }
        
    }];
    
    //连接设备连接过滤
//    [self.baby setFilterOnConnectToPeripheralsAtChannel:channel filter:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
//        
////        if ([peripheralName isEqualToString:@"AiJiu"]) {
////            return YES;
////        }
//        
//        return YES;
//    }];
    
    //读取返回处理
    [self.baby setBlockOnReadValueForCharacteristicAtChannel:channel block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        
        NSLog(@"==========\n Characteristic UUID:%@ ReadValue: %@ \n==========\n", characteristic.UUID,  characteristic.value);
        DeviceModel *model = [weakSelf getModelAtChannel:channel];;
        if ([characteristic isEqual:model.readCharateristic]) {

            for (id<DeviceManagerDelegate> delegate in weakSelf.delegateHashTable) {
                if ([delegate respondsToSelector:@selector(peripheralAtCharateristic:notifyData:)]) {
                    [delegate peripheralAtCharateristic:characteristic notifyData:characteristic.value];
                }
            }
        }
        
    }];
    
    //发送返回处理
    [self.baby setBlockOnDidWriteValueForCharacteristicAtChannel:channel block:^(CBCharacteristic *characteristic, NSError *error) {
        
        //发送成功，读取消息
//        NSLog(@"\n======\n WriteValue: %@ \n======\n", characteristic.value);
//        DeviceModel *model = [weakSelf.peripheralDic objectForKey:channel];
//        if (model) {
//            [model.periperal readValueForCharacteristic:model.readCharateristic];
//        }
    }];
    
    //特征码处理
    [self.baby setBlockOnDiscoverCharacteristicsAtChannel:channel block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        //
        DeviceModel *model = [weakSelf getModelAtChannel:channel];
        if (model) {
            
            NSLog(@"service：%@  \n======\n", service);
            
            //读写
            if ([[service.UUID UUIDString] isEqualToString:LIGHTBLUETOOTH_WRITE_SERVICE_UUID]) {
                
                for (CBCharacteristic *c in service.characteristics) {
                    if ([c.UUID.description isEqualToString:LIGHTBLUETOOTH_WRITE_CHARACTERISTICS_UUID]) {
                        model.writeCharateristic = c;
                    }
                }
            }
            
            if ([[service.UUID UUIDString] isEqualToString:LIGHTBLUETOOTH_NOTIFY_SERVICE_UUID]) {
                
                for (CBCharacteristic *c in service.characteristics) {
                    if ([c.UUID.description isEqualToString:LIGHTBLUETOOTH_NOTIFY_CHARACTERISTICS_UUID]) {
                        model.readCharateristic = c;
                        
                        [weakSelf.baby notify:peripheral characteristic:c block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                            
                            for (id<DeviceManagerDelegate> delegate in weakSelf.delegateHashTable) {
                                if ([delegate respondsToSelector:@selector(peripheralAtCharateristic:notifyData:)]) {
                                    [delegate peripheralAtCharateristic:characteristics notifyData:characteristics.value];
                                }
                            }
                        }];
                    }
                }
            }
            
            //配对
            if ([[service.UUID UUIDString] isEqualToString:LIGHTBLUETOOTH_PAIR_SERVICE_UUID]) {
                
                for (CBCharacteristic *c in service.characteristics) {
                    if ([c.UUID.description isEqualToString:LIGHTBLUETOOTH_PAIR_WRITE_CHARACTERISTICS_UUID]) {
                        model.pairWriteCharateristic = c;
                        
                        //配对密码
                        NSMutableData *sendData = [[NSMutableData alloc] init];
                        [sendData appendData:[weakSelf.passwordOld dataUsingEncoding:NSASCIIStringEncoding]];
                        [sendData appendData:[weakSelf.passwordNew dataUsingEncoding:NSASCIIStringEncoding]];
                        [peripheral writeValue:sendData forCharacteristic:c type:CBCharacteristicWriteWithResponse];
                        
                    }
                    
                    if ([c.UUID.description isEqualToString:LIGHTBLUETOOTH_PAIR_NOTIFY_CHARACTERISTICS_UUID]) {
                        model.pairReadCharateristic = c;
                        
                        [weakSelf.baby notify:peripheral characteristic:c block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                            
                            for (id<DeviceManagerDelegate> delegate in weakSelf.delegateHashTable) {
                                if ([delegate respondsToSelector:@selector(peripheralAtCharateristic:notifyData:)]) {
                                    [delegate peripheralAtCharateristic:characteristics notifyData:characteristics.value];
                                }
                            }
                        }];
                    }
                }
            }
 
        }
    }];
    
    //断开连接通知
    [self.baby setBlockOnDisconnectAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        //
        for (id<DeviceManagerDelegate> delegate in weakSelf.delegateHashTable) {
            if ([delegate respondsToSelector:@selector(peripheralDisconnectedAtChannel:)]) {
                [delegate peripheralDisconnectedAtChannel:channel];
            }
        }

    }];
    
}

- (void)listenNotify
{
    if (self.model.readCharateristic && self.model.periperal) {
        [self.baby notify:self.model.periperal characteristic:self.model.readCharateristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
            
            for (id<DeviceManagerDelegate> delegate in self.delegateHashTable) {
                if ([delegate respondsToSelector:@selector(peripheralAtCharateristic:notifyData:)]) {
                    [delegate peripheralAtCharateristic:characteristics notifyData:characteristics.value];
                }
            }
        }];
    }
}

- (void)scanAndConnectToPeripheralAtChannel:(NSString *)channel
{
    [self scanPeripheralAtChannel:channel autoConnect:YES];
}

//根据设备名称扫描链接
- (void)scanAndConnectPeripheralWithName:(NSString *)name oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword;
{
    self.passwordOld = oldPassword;
    self.passwordNew = newPassword;
    
    //扫描过滤
    [self.baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        if ([peripheralName isEqualToString:name]) {
            return YES;
        }
        
        return NO;
    }];
    
    //连接设备连接过滤
    [self.baby setFilterOnConnectToPeripheralsAtChannel:ChannelOne filter:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        if ([peripheralName isEqualToString:name]) {
            return YES;
        }
        
        return NO;
    }];
    
    [self scanPeripheralAtChannel:ChannelOne autoConnect:YES];
}

- (void)scanPeripheralAtChannel:(NSString *)channel autoConnect:(BOOL)isAutoConnect
{
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    
    //连接设备->
    [self.baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
    if (isAutoConnect) {
        self.baby.scanForPeripherals().and.then.connectToPeripherals().channel(channel).discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    }
    else {
        self.baby.scanForPeripherals().begin();
    }
    
}

- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    [self.baby cancelScan];
    
    self.baby.having(peripheral).and.then.connectToPeripherals().channel(ChannelOne).discoverServices().discoverCharacteristics().begin();
}


- (void)sendDataToPeripheralAtChannel:(NSString *)channel sendData:(NSData *)sendData
{
    
#ifdef TEST_FILTER_RESPOND
    NSLog(@"send data: %@", sendData);
#endif
    
    DeviceModel *model = [self.peripheralDic objectForKey:channel];
    if (model && model.periperal && model.writeCharateristic) {
        
//        if (model.readCharateristic) {
//            __weak typeof(self) weakSelf = self;
//            [self.baby notify:model.periperal characteristic:model.readCharateristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
//                
//                for (id<DeviceManagerDelegate> delegate in weakSelf.delegateHashTable) {
//                    if ([delegate respondsToSelector:@selector(peripheralAtCharateristic:notifyData:)]) {
//                        [delegate peripheralAtCharateristic:characteristics notifyData:characteristics.value];
//                    }
//                }
//            }];
//        }
        
        
        NSLog(@"\n=======\n SendData: %@ \n========\n", sendData);
        
        [model.periperal writeValue:sendData forCharacteristic:model.writeCharateristic type:CBCharacteristicWriteWithoutResponse];
    }
}

- (void)scanPeripheral
{
    [self.baby cancelScan];
    
    [self scanPeripheralAtChannel:ChannelOne autoConnect:NO];
}

- (void)sendDataToPeripheral:(NSData *)sendData
{
    [self sendDataToPeripheralAtChannel:ChannelOne sendData:sendData];
}

- (void)readData
{
    DeviceModel *model = [self.peripheralDic objectForKey:ChannelOne];
    if (model.periperal) {
        [model.periperal readValueForCharacteristic:model.readCharateristic];
    }
}

- (void)disconnectPeripheral
{
    [self.baby cancelAllPeripheralsConnection];
}

@end
