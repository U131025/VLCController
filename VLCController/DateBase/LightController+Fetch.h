//
//  LightController+Fetch.h
//  VLCController
//
//  Created by mojingyu on 16/1/20.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "LightController+CoreDataClass.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <objc/runtime.h>
#import "LightControllerModel.h"

//typedef enum
//{
//    Paired,
//    UnPair,
//}PeripheralStatus;

@interface LightController (Fetch)

@property (nonatomic, strong) CBPeripheral *peripheral;


//+ (LightControllerModel *)convertToModel:(LightController *)light;

//+ (LightController *)getLightControllerWithMacAddress:(NSString *)macAddress inManagedObjectContext:(NSManagedObjectContext *)context;

//+ (LightController *)getLightControllerWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
//
//+ (LightController *)addLightController:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

//+ (BOOL)addLightControllers:(NSArray *)lightControllersArray inManagedObjectContext:(NSManagedObjectContext *)context;

//+ (BOOL)deleteLightController:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)getAllLightControllersInManagedObjectContext:(NSManagedObjectContext *)context;

+ (LightController *)getObjectWithIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)context;

+ (LightController *)addObjectWithIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)context;

+ (BOOL)deleteObject:(LightController *)object inManagedObjectContext:(NSManagedObjectContext *)context;

@end
