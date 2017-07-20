//
//  ScheduleItem+CoreDataProperties.m
//  VLCController
//
//  Created by Mojy on 2017/6/2.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "ScheduleItem+CoreDataProperties.h"

@implementation ScheduleItem (CoreDataProperties)

+ (NSFetchRequest<ScheduleItem *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ScheduleItem"];
}

@dynamic date;
@dynamic isSelected;
@dynamic name;
@dynamic themeName;
@dynamic schedule;

@end
