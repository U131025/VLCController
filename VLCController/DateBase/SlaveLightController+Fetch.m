//
//  SlaveLightController+Fetch.m
//  VLCController
//
//  Created by mojingyu on 16/1/29.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "SlaveLightController+Fetch.h"

@implementation SlaveLightController (Fetch)

@dynamic peripheral;

- (CBPeripheral *)peripheral
{
    return objc_getAssociatedObject(self, @selector(peripheral));
}

- (void)setPeripheral:(CBPeripheral *)peripheral
{
    objc_setAssociatedObject(self, @selector(peripheral), peripheral, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSArray *)fetchSlavesFromMaster:(LightController *)master inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!master) return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SlaveLightController" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"master == %@", master];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = NULL;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    return array;
}

+ (SlaveLightController *)getSlaveWithName:(NSString *)slaveName withMaster:(LightController *)master inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!slaveName || !master) {
        return nil;
    }
    
    SlaveLightController *finder = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"SlaveLightController" inManagedObjectContext:context]];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@ AND master == %@", slaveName, master];
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

+ (SlaveLightController *)addSlaveWithName:(NSString *)slaveName withMaster:(LightController *)master inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!master) {
        return nil;
    }
    
    SlaveLightController *newSlave = [self getSlaveWithName:slaveName withMaster:master inManageObjectContext:context];
    if (!newSlave) {
        newSlave = [NSEntityDescription insertNewObjectForEntityForName:@"SlaveLightController" inManagedObjectContext:context];
    }
    
    newSlave.name = slaveName;
    newSlave.master = master;
    
    return newSlave;
}

+ (void)removeSlave:(SlaveLightController *)slave inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!slave) {
        return;
    }
    
    [context deleteObject:slave];
}
@end
