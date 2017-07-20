//
//  DeviceManager.h
//  zhenjiu
//
//  Created by mojingyu on 2017/4/3.
//  Copyright © 2017年 com.huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceModel.h"

#define ChannelOne @"Channel_One"
#define ChannelTwo @"Channel_Two"
#define ChannelThree @"Channel_Three"
#define ChannelFour @"Channel_Four"

//#define LIGHTBLUETOOTH_WRITE_SERVICE_UUID @"FFE0"
#define LIGHTBLUETOOTH_WRITE_SERVICE_UUID @"FFE5"
#define LIGHTBLUETOOTH_WRITE_CHARACTERISTICS_UUID @"FFE9"

#define LIGHTBLUETOOTH_NOTIFY_SERVICE_UUID @"FFE0"
#define LIGHTBLUETOOTH_NOTIFY_CHARACTERISTICS_UUID @"FFE4"

#define LIGHTBLUETOOTH_PAIR_SERVICE_UUID @"FFC0"
#define LIGHTBLUETOOTH_PAIR_WRITE_CHARACTERISTICS_UUID @"FFC1"
#define LIGHTBLUETOOTH_PAIR_NOTIFY_CHARACTERISTICS_UUID @"FFC2"

#define LED_MACADDR_SERVICE_UUID @"FEE7"
#define LED_MACADDR_WRITE_CHARACTERISTICS_UUID @"FEC7"
#define LED_MACADDR_NOTIFY_CHARACTERISTICS_UUID @"FEC8"
#define LED_MACADDR_READ_CHARACTERISTICS_UUID @"FEC9"

@protocol DeviceManagerDelegate <NSObject>

@optional
- (void)peripheralDiscovered:(CBPeripheral *)peripheral;

- (void)peripheralConnectedAtChannel:(NSString *)channel;

- (void)peripheralDisconnectedAtChannel:(NSString *)channel;

- (void)peripheralAtCharateristic:(CBCharacteristic *)charateristic notifyData:(NSData *)notifyData;

- (void)peripheralTimeoutAtChannel:(NSString *)channel;

@end

@interface DeviceManager : NSObject

@property (nonatomic, weak) id<DeviceManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *peripheralDic; //key:channel value:DeviceModel
@property (nonatomic, copy) NSString *selectedChannel;
@property (nonatomic, strong) NSMutableSet *deviceSet;  //搜索到的设备

@property (nonatomic, assign) BOOL bluetoothOpenStatue;

@property (nonatomic, readonly, weak) DeviceModel *model;

+ (instancetype)sharedInstance;

- (void)scanPeripheralAtChannel:(NSString *)channel autoConnect:(BOOL)isAutoConnect;

- (void)scanAndConnectToPeripheralAtChannel:(NSString *)channel;

//根据设备名称扫描链接
- (void)scanAndConnectPeripheralWithName:(NSString *)name oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword;

- (void)sendDataToPeripheralAtChannel:(NSString *)channel sendData:(NSData *)sendData;

- (void)scanPeripheral;

- (void)connectPeripheral:(CBPeripheral *)peripheral;

- (void)sendDataToPeripheral:(NSData *)sendData;

- (void)readData;

- (void)disconnectPeripheral;

@end
