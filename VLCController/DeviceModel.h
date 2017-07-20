//
//  DeviceModel.h
//  zhenjiu
//
//  Created by mojingyu on 2017/4/4.
//  Copyright © 2017年 com.huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


typedef NS_ENUM(NSInteger, DeviceStatus) {
    DeviceStatusConnected = 0,
    DeviceStatusConecctedAndSelected,
    DeviceStatusDisconnected,
};

@interface DeviceModel : NSObject

@property (nonatomic, strong) CBPeripheral *periperal;
@property (nonatomic, strong) CBCharacteristic *writeCharateristic;
@property (nonatomic, strong) CBCharacteristic *readCharateristic;

@property (nonatomic, strong) CBCharacteristic *pairWriteCharateristic;
@property (nonatomic, strong) CBCharacteristic *pairReadCharateristic;

@property (nonatomic, strong) CBCharacteristic *macWriteCharateristic;
@property (nonatomic, strong) CBCharacteristic *macReadCharateristic;
@property (nonatomic, strong) CBCharacteristic *macNotifyCharateristic;

@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, assign) NSInteger index;

@end
