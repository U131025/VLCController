//
//  Schedule+CoreDataProperties.h
//  VLCController
//
//  Created by mojingyu on 16/3/8.
//  Copyright © 2016年 Mojy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Schedule.h"

NS_ASSUME_NONNULL_BEGIN

@interface Schedule (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *timeOn;
@property (nullable, nonatomic, retain) NSString *timeOff;
@property (nullable, nonatomic, retain) NSNumber *isPhotoCell;
@property (nullable, nonatomic, retain) NSNumber *isCustomSchedule;
@property (nullable, nonatomic, retain) LightController *lightController;
@property (nullable, nonatomic, retain) NSSet<ScheduleItem *> *items;

@end

@interface Schedule (CoreDataGeneratedAccessors)

- (void)addItemsObject:(ScheduleItem *)value;
- (void)removeItemsObject:(ScheduleItem *)value;
- (void)addItems:(NSSet<ScheduleItem *> *)values;
- (void)removeItems:(NSSet<ScheduleItem *> *)values;

@end

NS_ASSUME_NONNULL_END
