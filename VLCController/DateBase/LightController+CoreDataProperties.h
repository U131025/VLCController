//
//  LightController+CoreDataProperties.h
//  VLCController
//
//  Created by Mojy on 2017/6/2.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "LightController+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface LightController (CoreDataProperties)

+ (NSFetchRequest<LightController *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *controllerType;
@property (nullable, nonatomic, copy) NSString *deviceName;
@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, copy) NSNumber *isCustomSchedule;
@property (nullable, nonatomic, copy) NSNumber *isPairBulbs;
@property (nullable, nonatomic, copy) NSNumber *isPowerOn;
@property (nullable, nonatomic, copy) NSString *lightID;
@property (nullable, nonatomic, copy) NSString *macAddress;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *password;
@property (nullable, nonatomic, copy) NSString *themeName;
@property (nullable, nonatomic, copy) NSNumber *useLightSchedule;
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
