//
//  Schedule+CoreDataProperties.m
//  VLCController
//
//  Created by Mojy on 2017/6/2.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "Schedule+CoreDataProperties.h"

@implementation Schedule (CoreDataProperties)

+ (NSFetchRequest<Schedule *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Schedule"];
}

@dynamic isCustomSchedule;
@dynamic isPhotoCell;
@dynamic name;
@dynamic timeOff;
@dynamic timeOn;
@dynamic items;
@dynamic lightController;

@end
