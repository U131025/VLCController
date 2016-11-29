//
//  ScheduleItem+Fetch.m
//  VLCController
//
//  Created by mojingyu on 16/3/8.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ScheduleItem+Fetch.h"

@implementation ScheduleItem (Fetch)

+ (NSArray *)fetchWithSchedule:(Schedule *)scheduleObject inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!scheduleObject) return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ScheduleItem" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = nil;
    
    if (scheduleObject) {
        predicate = [NSPredicate predicateWithFormat:@"schedule == %@", scheduleObject];
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error = NULL;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    if (array) {
        //进行排序
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSString *strObj1 = (NSString *)obj1;
            NSString *strObj2 = (NSString *)obj2;

            @try {
                NSInteger selfInteger = [strObj1 integerValue];
                NSInteger otherInteger = [strObj2 integerValue];
                if (selfInteger == otherInteger) {
                    return NSOrderedSame;
                } else if (selfInteger > otherInteger) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }
            @catch (NSException *exception) {
                return NSOrderedSame;
            }
            
        }];
        
        NSArray *newArray = [array sortedArrayUsingDescriptors:@[sortDescriptor]];
//        NSLog(@"%@", newArray);
        return newArray;
    }
    
    return array;
}

+ (ScheduleItem *)getWithWithName:(NSString *)name withSchedule:(Schedule *)scheduleObject inManageObjectContext:(NSManagedObjectContext *)context
{
    if (name == nil) {
        return nil;
    }
    
    ScheduleItem *finder = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ScheduleItem" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = nil;
    predicate = [NSPredicate predicateWithFormat:@"name == %@ AND schedule == %@", name, scheduleObject];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = NULL;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    if (array && (array.count > 0)) {
        finder = [array objectAtIndex:0];
    }
    return finder;
}

+ (ScheduleItem *)addWithName:(NSString *)name withSchedule:(Schedule *)scheduleObject inManageObjectContext:(NSManagedObjectContext *)context
{
    if (name == nil) {
        return nil;
    }
    
    ScheduleItem *newObject = [self getWithWithName:name withSchedule:scheduleObject inManageObjectContext:context];
    
    if (!newObject) {
        newObject = [NSEntityDescription insertNewObjectForEntityForName:@"ScheduleItem" inManagedObjectContext:context];
        newObject.name = name;
        newObject.schedule = scheduleObject;
    }
    
    return newObject;
}

+ (void)removeTheme:(ScheduleItem *)object inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!object) return;
    
    [context deleteObject:object];
}


@end
