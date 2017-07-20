//
//  LightController+Fetch.m
//  VLCController
//
//  Created by mojingyu on 16/1/20.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "LightController+Fetch.h"
#import "DateFuncation.h"

@implementation LightController (Fetch)

@dynamic peripheral;

- (CBPeripheral *)peripheral
{
    return objc_getAssociatedObject(self, @selector(peripheral));
}

- (void)setPeripheral:(CBPeripheral *)peripheral
{
    objc_setAssociatedObject(self, @selector(peripheral), peripheral, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (LightControllerModel *)convertToModel:(LightController *)light
{
    LightControllerModel *model = [[LightControllerModel alloc] init];
    model.name = light.name;    
    
    return model;
}

+ (LightController *)getLightControllerWithMacAddress:(NSString *)macAddress inManagedObjectContext:(NSManagedObjectContext *)context
{
    return nil;
}

+ (LightController *)getLightControllerWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    LightController *light = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *lightEntity = [NSEntityDescription entityForName:@"LightController" inManagedObjectContext:context];
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
    
    if (array && array.count > 0) {
        light = [array objectAtIndex:0];
    }
    
    return light;
}

+ (LightController *)addLightController:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (!name) {
        return nil;
    }
    
    LightController *newLightController = [self getLightControllerWithName:name inManagedObjectContext:context];
    if (!newLightController) {
        newLightController = [NSEntityDescription insertNewObjectForEntityForName:@"LightController" inManagedObjectContext:context];
    }
    
    if (!newLightController.lightID) {
        //添加时间戳作为ID
        newLightController.lightID = [DateFuncation getTimeSp];
    }
    newLightController.name = name;
    
    return newLightController;
}

+ (BOOL)deleteLightController:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    LightController *lightFinder = [self getLightControllerWithName:name inManagedObjectContext:context];
    if (lightFinder) {
        [context deleteObject:lightFinder];
    }
    
    return YES;
}

+ (NSArray *)getAllLightControllersInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"LightController" inManagedObjectContext:context]];
    
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

+ (LightController *)getObjectWithIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)context
{
    LightController *light = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *lightEntity = [NSEntityDescription entityForName:@"LightController" inManagedObjectContext:context];
    [fetchRequest setEntity:lightEntity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = NULL;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        MyLog(@"Error: %@", [error localizedDescription]);
    }
    
    if (array && array.count > 0) {
        light = [array objectAtIndex:0];
    }
    
    return light;

}

+ (LightController *)addObjectWithIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (!identifier) {
        return nil;
    }
    
    LightController *newLightController = [self getObjectWithIdentifier:identifier inManagedObjectContext:context];
    if (!newLightController) {
        newLightController = [NSEntityDescription insertNewObjectForEntityForName:@"LightController" inManagedObjectContext:context];
        
    }
    
    if (!newLightController.lightID) {
        //添加时间戳作为ID
        newLightController.lightID = [DateFuncation getTimeSp];
    }
    
    if (!newLightController.identifier) {
        newLightController.identifier = identifier;
    }
    
    newLightController.isPairBulbs = [[NSNumber alloc] initWithBool:NO];
    return newLightController;
}

+ (BOOL)deleteObject:(LightController *)object inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (object) {
        [context deleteObject:object];
        return YES;
    }
    return NO;
}

@end
