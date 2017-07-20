//
//  Theme+Fetch.m
//  VLCController
//
//  Created by mojingyu on 16/1/29.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "Theme+Fetch.h"

@implementation Theme (Fetch)

+ (NSArray *)fetchThemesWithLightController:(LightController *)lightObject inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!lightObject) return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Theme" inManagedObjectContext:context];
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

+ (Theme *)getThemeWithWithName:(NSString *)themeName withLightController:(LightController *)lightObject inManageObjectContext:(NSManagedObjectContext *)context
{
    if (themeName == nil) {
        return nil;
    }
    
    Theme *finderTheme = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Theme" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = nil;
    
    if (lightObject) {
        predicate = [NSPredicate predicateWithFormat:@"name == %@ AND lightController == %@", themeName, lightObject];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"name == %@", themeName];
    }
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = NULL;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    if (array && (array.count > 0)) {
        finderTheme = [array objectAtIndex:0];
    }
    return finderTheme;
}

+ (Theme *)addThemeWithName:(NSString *)themeName withLightController:(LightController *)light inManageObjectContext:(NSManagedObjectContext *)context
{
    if (themeName == nil) {
        return nil;
    }
    
    Theme *newTheme = [self getThemeWithWithName:themeName withLightController:light inManageObjectContext:context];
    if (!newTheme) {
        newTheme = [NSEntityDescription insertNewObjectForEntityForName:@"Theme" inManagedObjectContext:context];
    }
    
    newTheme.name = themeName;
    newTheme.themeName = themeName;
    newTheme.lightController = light;
    return newTheme;
}

+ (void)removeTheme:(Theme *)themeObject inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!themeObject) return;
    
    [context deleteObject:themeObject];
}
@end
