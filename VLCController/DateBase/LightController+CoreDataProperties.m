//
//  LightController+CoreDataProperties.m
//  VLCController
//
//  Created by Mojy on 2017/6/2.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "LightController+CoreDataProperties.h"

@implementation LightController (CoreDataProperties)

+ (NSFetchRequest<LightController *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"LightController"];
}

@dynamic controllerType;
@dynamic deviceName;
@dynamic identifier;
@dynamic isCustomSchedule;
@dynamic isPairBulbs;
@dynamic isPowerOn;
@dynamic lightID;
@dynamic macAddress;
@dynamic name;
@dynamic password;
@dynamic themeName;
@dynamic useLightSchedule;
@dynamic bulbChannels;
@dynamic lightThemes;
@dynamic master;
@dynamic schedules;
@dynamic slave;

@end
