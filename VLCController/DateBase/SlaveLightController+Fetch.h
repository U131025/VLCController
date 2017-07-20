//
//  SlaveLightController+Fetch.h
//  VLCController
//
//  Created by mojingyu on 16/1/29.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "SlaveLightController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <objc/runtime.h>

@interface SlaveLightController (Fetch)

@property (nonatomic, strong) CBPeripheral *peripheral; 

+ (NSArray *)fetchSlavesFromMaster:(LightController *)master inManageObjectContext:(NSManagedObjectContext *)context;

+ (SlaveLightController *)getSlaveWithName:(NSString *)slaveName withMaster:(LightController *)master inManageObjectContext:(NSManagedObjectContext *)context;

+ (SlaveLightController *)addSlaveWithName:(NSString *)slaveName withMaster:(LightController *)master inManageObjectContext:(NSManagedObjectContext *)context;

+ (void)removeSlave:(SlaveLightController *)slave inManageObjectContext:(NSManagedObjectContext *)context;

@end
