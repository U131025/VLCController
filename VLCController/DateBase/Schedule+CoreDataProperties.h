//
//  Schedule+CoreDataProperties.h
//  VLCController
//
//  Created by Mojy on 2017/6/2.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "Schedule+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Schedule (CoreDataProperties)

+ (NSFetchRequest<Schedule *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *isCustomSchedule;
@property (nullable, nonatomic, copy) NSNumber *isPhotoCell;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *timeOff;
@property (nullable, nonatomic, copy) NSString *timeOn;
@property (nullable, nonatomic, retain) NSSet<ScheduleItem *> *items;
@property (nullable, nonatomic, retain) LightController *lightController;

@end

@interface Schedule (CoreDataGeneratedAccessors)

- (void)addItemsObject:(ScheduleItem *)value;
- (void)removeItemsObject:(ScheduleItem *)value;
- (void)addItems:(NSSet<ScheduleItem *> *)values;
- (void)removeItems:(NSSet<ScheduleItem *> *)values;

@end

NS_ASSUME_NONNULL_END
