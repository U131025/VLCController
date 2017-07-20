//
//  BulbChannel+Fetch.m
//  VLCController
//
//  Created by mojingyu on 16/3/10.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "BulbChannel+Fetch.h"

@implementation BulbChannel (Fetch)

+ (NSArray *)fetchWithLightController:(LightController *)lightObject inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!lightObject) return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BulbChannel" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
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

+ (BulbChannel *)getWithWithName:(NSString *)name withLightController:(LightController *)lightObject inManageObjectContext:(NSManagedObjectContext *)context
{
    if (name == nil) {
        return nil;
    }
    
    BulbChannel *finder = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BulbChannel" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
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

+ (BulbChannel *)addWithName:(NSString *)name withLightController:(LightController *)light inManageObjectContext:(NSManagedObjectContext *)context
{
    if (name == nil) {
        return nil;
    }
    
    BulbChannel *newObject = [self getWithWithName:name withLightController:light inManageObjectContext:context];
    if (!newObject) {
        newObject = [NSEntityDescription insertNewObjectForEntityForName:@"BulbChannel" inManagedObjectContext:context];
        newObject.name = name;
        newObject.lightController = light;
    }
    
    return newObject;
}

+ (void)removeObject:(BulbChannel *)object inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!object) return;
    
    [context deleteObject:object];
}

@end
