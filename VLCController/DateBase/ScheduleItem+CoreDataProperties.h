//
//  ScheduleItem+CoreDataProperties.h
//  VLCController
//
//  Created by mojingyu on 16/3/8.
//  Copyright © 2016年 Mojy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ScheduleItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScheduleItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *date;
@property (nullable, nonatomic, retain) NSString *themeName;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *isSelected;
@property (nullable, nonatomic, retain) Schedule *schedule;

@end

NS_ASSUME_NONNULL_END
