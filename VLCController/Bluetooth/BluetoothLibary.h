//
//  BluetoothLibary.h
//  BluetoothLibary
//
//  Created by JuLong on 15/6/17.
//  Copyright (c) 2015年 julong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BluetoothLibaryDelegate <NSObject>

//发现蓝牙设备
- (void)didDiscoverPeripheral:(CBPeripheral *)peripheral;

//连接成功
- (void)connetctSuccess:(CBPeripheral *)peripheral;

//接收外设发送数据
- (void)updateValueForPeripheral:(NSData *)data;

//返回的mac地址数据
- (void)reciveMacAddressData:(NSData *)data;

// 断开连接消息
- (void)didDisconnectPeripheral;

@end

@interface BluetoothLibary : NSObject
{
    id<BluetoothLibaryDelegate> delegate;
}

@property (nonatomic, strong) NSString *serviceUUID;
@property (nonatomic, strong) NSString *readUUID;
@property (nonatomic, strong) NSString *writeUUID;
@property (nonatomic, strong) NSString *notifyUUID;
@property (nonatomic, strong) NSMutableArray *devices; //of CBPeripheral

@property (nonatomic, weak) id<BluetoothLibaryDelegate> delegate;

// 根据UUID进行扫描
// (in) isReset : 是否重新开始扫描
// (in) timeoutSeconds : 超时时间，超过N秒后，自动停止扫描
- (void)startScan:(NSString *)serviceUUID inReadUUID:(NSString *)readUUID inWriteUUID:(NSString *)writeUUID inTimeOutSeconds:(int)timeOutSeconds;

// 扫描所有设备
- (BOOL)startScanWithReset:(BOOL)reset withTimeOut:(NSInteger)seconds withTimeOutBlock:(void(^)())timeOutBlock;

// 停止扫描
- (void)stopScan;

// 手动连接设备
- (void)connectPeripheral:(CBPeripheral *)peripheral withServiceUUID:(NSString *)serviceUUID withReadUUID:(NSString *)readUUID withWriteUUID:(NSString *)writeUUID;

//手动连接蓝牙外设
- (void)connectPeripheral:(CBPeripheral *)peripheral;

// 断开连接
- (void)disConnectPeripheral;
- (void)disConnectPeripheral:(CBPeripheral *)peripheral onFinished:(void (^)())onFinished;

// 发送数据至蓝牙设备
- (void)sendDataToPeripheral:(NSData *)sendData;

@end
