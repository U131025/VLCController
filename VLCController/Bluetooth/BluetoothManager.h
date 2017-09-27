//
//  BluetoothManager.h
//  VLCController
//
//  Created by mojingyu on 16/1/21.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "BluetoothLibary.h"
#import "LightControllerModel.h"
#import "DeviceModel.h"
#import "DeviceManager.h"

typedef NS_ENUM(NSInteger, BLERespondType) {
    BLERespondTypeRead,
    BLERespondTypePairPWD,
    BLERespondTypeMacAddr,
    BLERespondTypeTimeout,
    
    BLERespondTypeFailure,
    BLERespondTypeSuccess,
};

typedef void(^RespondBlock)(NSData *data);
typedef void(^BluetoothCompleteBlock)(CBPeripheral *peripheral, id data, BLERespondType type);
typedef void(^BLEConnectSuccess)(CBPeripheral *peripheral);
typedef void(^BLEConnectFailed)(CBPeripheral *peripheral);
typedef void (^DisconnectedPeripheral)(CBPeripheral *peripheral);

/////////////////// BluetoothManagerDelegate
//@protocol BluetoothManagerDelegate <NSObject>
//
//- (void)receiveTimeOut:(CBPeripheral *)peripheral;
//- (void)receiveSuccess:(NSData *)data;
//
//@optional
//
//- (void)bluetoothDisConnected;
//
//@end


/////////////// BluetoothManager

@interface BluetoothManager : NSObject

//单例
DECLARE_SINGLETON(BluetoothManager);

@property (nonatomic, copy) NSArray *device;   //of CBPeripheral
@property (nonatomic, assign) NSInteger timeOutSeconds;
//@property (nonatomic, weak) id<BluetoothManagerDelegate> delegate;
@property (nonatomic, readonly, weak) CBPeripheral *peripheral;
@property (nonatomic, assign) BOOL isBluetoothOpen;
@property (nonatomic, assign) BOOL isConnectedPeripheral;

@property (nonatomic, copy) DisconnectedPeripheral disconnectedBlock;

- (void)connectWithName:(NSString *)name oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword successBlock:(BluetoothCompleteBlock)success faileBlock:(BluetoothCompleteBlock)failed;

- (void)disconnectAllPeripheral;

- (void)sendData:(NSData *)sendData onRespond:(BOOL (^)(NSData *data))respond onTimeOut:(void (^)())timeOut;

- (void)sendData:(NSData *)sendData onRespond:(BOOL (^)(NSData *))respond timeOutValue:(NSInteger)timeOutValue onTimeOut:(void (^)())timeOut;

- (void)readDataWithRespond:(BOOL (^)(NSData *data))respond timeOutValue:(NSInteger)timeOutValue onTimeOut:(void (^)())timeOut;

- (void)setBlockForDisconnected:(DisconnectedPeripheral)disconnectedBlock;

@end
