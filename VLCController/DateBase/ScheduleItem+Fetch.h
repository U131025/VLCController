//
//  ScheduleItem+Fetch.h
//  VLCController
//
//  Created by mojingyu on 16/3/8.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ScheduleItem+CoreDataClass.h"

@interface ScheduleItem (Fetch)

+ (NSArray *)fetchWithSchedule:(Schedule *)scheduleObject inManageObjectContext:(NSManagedObjectContext *)context;

+ (ScheduleItem *)getWithWithName:(NSString *)name withSchedule:(Schedule *)scheduleObject inManageObjectContext:(NSManagedObjectContext *)context;

+ (ScheduleItem *)addWithName:(NSString *)name withSchedule:(Schedule *)scheduleObject inManageObjectContext:(NSManagedObjectContext *)context;

+ (void)removeTheme:(ScheduleItem *)object inManageObjectContext:(NSManagedObjectContext *)context;

+ (ScheduleItem *)getObjectWithDate:(NSString *)date withSchedule:(Schedule *)scheduleObject inManageObjectContext:(NSManagedObjectContext *)context;

@end
