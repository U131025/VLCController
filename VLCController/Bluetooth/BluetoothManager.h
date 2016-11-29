//
//  BluetoothManager.h
//  VLCController
//
//  Created by mojingyu on 16/1/21.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BluetoothLibary.h"
#import "LightControllerModel.h"

@protocol BluetoothManagerDelegate <NSObject>

- (void)receiveTimeOut:(CBPeripheral *)peripheral;
- (void)receiveSuccess:(NSData *)data;

@optional

- (void)bluetoothDisConnected;

@end

@interface BluetoothManager : NSObject

//单例
DECLARE_SINGLETON(BluetoothManager);

@property (nonatomic, strong) NSMutableArray *device;   //of CBPeripheral
@property (nonatomic, assign) NSInteger timeOutSeconds;
@property (nonatomic, weak) id<BluetoothManagerDelegate> delegate;
@property (nonatomic, strong) CBPeripheral *peripheral;

- (BOOL)startScanBluetooth;
- (BOOL)connectPeripheral:(CBPeripheral *)peripheral onSuccessBlock:(void (^)())onSuccessBlock onTimeoutBlock:(void (^)())onTimeoutBlock;
- (void)disConnectPeripheral;

- (void)disConnectPeripheral:(void (^)())onFinished;
- (void)disConnectPeripheral:(CBPeripheral *)periphseral onFinished:(void (^)())onFinished;

// 发送数据至蓝牙设备
- (void)sendDataToPeripheral:(NSData *)sendData;
- (void)sendDataToPeripheral:(NSData *)sendData withIdentifier:(NSString *)identifier;

- (void)sendData:(NSData *)sendData onRespond:(BOOL (^)(NSData *data))respond onTimeOut:(void (^)())timeOut;
- (void)sendData:(NSData *)sendData withIdentifier:(NSString *)identifier onRespond:(BOOL (^)(NSData *data))respond onTimeOut:(void (^)())timeOut;

- (CBPeripheral *)getPeripheralWithIdentifier:(NSString *)identifier;


//根据identifier搜索设备
- (void)scanBluetoothWithIdentifier:(NSString *)identifier onSuccessBlock:(void (^)())onSuccessBlock onTimeoutBlock:(void (^)())onTimeoutBlock;

//是否设备处于连接状态
- (BOOL)isConnectedPeripheral;

@end
