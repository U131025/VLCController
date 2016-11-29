//
//  Schedule+Fetch.m
//  VLCController
//
//  Created by mojingyu on 16/3/8.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "Schedule+Fetch.h"

@implementation Schedule (Fetch)

+ (NSArray *)fetchWithLightController:(LightController *)lightObject inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!lightObject) return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Schedule" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = nil;
    
    if (lightObject) {
        predicate = [NSPredicate predicateWithFormat:@"lightController == %@", lightObject];
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error = NULL;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    return array;
}

+ (Schedule *)getWithWithName:(NSString *)name withLightController:(LightController *)lightObject inManageObjectContext:(NSManagedObjectContext *)context
{
    if (name == nil) {
        return nil;
    }
    
    Schedule *finder = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Schedule" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = nil;    
    predicate = [NSPredicate predicateWithFormat:@"name == %@ AND lightController == %@", name, lightObject];
    
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

+ (Schedule *)addWithName:(NSString *)name withLightController:(LightController *)light inManageObjectContext:(NSManagedObjectContext *)context
{
    if (name == nil) {
        return nil;
    }
    
    Schedule *newObject = [self getWithWithName:name withLightController:light inManageObjectContext:context];
    if (!newObject) {
        newObject = [NSEntityDescription insertNewObjectForEntityForName:@"Schedule" inManagedObjectContext:context];
        newObject.name = name;
        newObject.lightController = light;
    }
    
    return newObject;
}

+ (void)removeTheme:(Schedule *)object inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!object) return;
    
    [context deleteObject:object];
}
@end
