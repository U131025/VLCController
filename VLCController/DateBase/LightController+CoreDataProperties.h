//
//  LightController+CoreDataProperties.h
//  VLCController
//
//  Created by mojingyu on 16/9/24.
//  Copyright © 2016年 Mojy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LightController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LightController (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *controllerType;
@property (nullable, nonatomic, retain) NSString *deviceName;
@property (nullable, nonatomic, retain) NSString *identifier;
@property (nullable, nonatomic, retain) NSNumber *isCustomSchedule;
@property (nullable, nonatomic, retain) NSNumber *isPairBulbs;
@property (nullable, nonatomic, retain) NSNumber *isPowerOn;
@property (nullable, nonatomic, retain) NSString *macAddress;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *themeName;
@property (nullable, nonatomic, retain) NSNumber *useLightSchedule;
@property (nullable, nonatomic, retain) NSString *lightID;
@property (nullable, nonatomic, retain) NSSet<BulbChannel *> *bulbChannels;
@property (nullable, nonatomic, retain) NSSet<Theme *> *lightThemes;
@property (nullable, nonatomic, retain) LightController *master;
@property (nullable, nonatomic, retain) NSSet<Schedule *> *schedules;
@property (nullable, nonatomic, retain) LightController *slave;

@end

@interface LightController (CoreDataGeneratedAccessors)

- (void)addBulbChannelsObject:(BulbChannel *)value;
- (void)removeBulbChannelsObject:(BulbChannel *)value;
- (void)addBulbChannels:(NSSet<BulbChannel *> *)values;
- (void)removeBulbChannels:(NSSet<BulbChannel *> *)values;

- (void)addLightThemesObject:(Theme *)value;
- (void)removeLightThemesObject:(Theme *)value;
- (void)addLightThemes:(NSSet<Theme *> *)values;
- (void)removeLightThemes:(NSSet<Theme *> *)values;

- (void)addSchedulesObject:(Schedule *)value;
- (void)removeSchedulesObject:(Schedule *)value;
- (void)addSchedules:(NSSet<Schedule *> *)values;
- (void)removeSchedules:(NSSet<Schedule *> *)values;

@end

NS_ASSUME_NONNULL_END
