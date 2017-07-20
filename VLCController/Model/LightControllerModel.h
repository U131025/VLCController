//
//  LightControllerModel.h
//  VLCController
//
//  Created by mojingyu on 16/1/13.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef enum
{
    Normal,
    Master,
    Slave,
    
}ControllerType;

typedef enum
{
    Paired,
    UnPair,
}ControllerStatus;

@interface LightControllerModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *lightID;
@property (nonatomic, copy) NSString *macAddress; //设备的MAC地址,唯一匹配标识
@property (nonatomic, copy) NSString *password; //密码

@property (nonatomic, strong) CBPeripheral *peripheral; 

@property (nonatomic, assign) ControllerType type;
@property (nonatomic, assign) ControllerStatus status;

@property (nonatomic, strong) NSMutableArray *slaveArray; // of LightControllerModel

- (id)initWithLightController:(LightController *)lightController;

@end
