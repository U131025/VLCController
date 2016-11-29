//
//  Schedule+Fetch.h
//  VLCController
//
//  Created by mojingyu on 16/3/8.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "Schedule.h"

@interface Schedule (Fetch)

+ (NSArray *)fetchWithLightController:(LightController *)lightObject inManageObjectContext:(NSManagedObjectContext *)context;

+ (Schedule *)getWithWithName:(NSString *)name withLightController:(LightController *)lightObject inManageObjectContext:(NSManagedObjectContext *)context;

+ (Schedule *)addWithName:(NSString *)name withLightController:(LightController *)light inManageObjectContext:(NSManagedObjectContext *)context;

+ (void)removeTheme:(Schedule *)object inManageObjectContext:(NSManagedObjectContext *)context;

@end
