//
//  ScheduleItem+CoreDataProperties.h
//  VLCController
//
//  Created by Mojy on 2017/6/2.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "ScheduleItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ScheduleItem (CoreDataProperties)

+ (NSFetchRequest<ScheduleItem *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *date;
@property (nullable, nonatomic, copy) NSNumber *isSelected;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *themeName;
@property (nullable, nonatomic, retain) Schedule *schedule;

@end

NS_ASSUME_NONNULL_END
