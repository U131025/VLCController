//
//  ColorFavorites+Fetch.m
//  VLCController
//
//  Created by mojingyu on 16/3/10.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ColorFavorites+Fetch.h"

@implementation ColorFavorites (Fetch)

+ (ColorFavorites *)getObjectWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *lightEntity = [NSEntityDescription entityForName:@"ColorFavorites" inManagedObjectContext:context];
    [fetchRequest setEntity:lightEntity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = NULL;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        MyLog(@"Error: %@", [error localizedDescription]);
    }
    
    ColorFavorites *finder = nil;
    if (array && array.count > 0) {
        finder = [array objectAtIndex:0];
    }
    
    return finder;
}

+ (ColorFavorites *)addObject:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (!name) {
        return nil;
    }
    
    ColorFavorites *newObject = [self getObjectWithName:name inManagedObjectContext:context];
    if (!newObject) {
        newObject = [NSEntityDescription insertNewObjectForEntityForName:@"ColorFavorites" inManagedObjectContext:context];
    }
    
    newObject.name = name;
    
    return newObject;
}

+ (BOOL)removeObject:(ColorFavorites *)object inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (object) {
        [context deleteObject:object];
        return YES;
    }
    
    return NO;
}

+ (NSArray *)fetchObjectsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ColorFavorites" inManagedObjectContext:context]];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@""];
    
    NSError *error = NULL;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    return array;
}

@end
