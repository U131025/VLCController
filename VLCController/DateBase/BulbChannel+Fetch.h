//
//  BulbChannel+Fetch.h
//  VLCController
//
//  Created by mojingyu on 16/3/10.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "BulbChannel.h"

@interface BulbChannel (Fetch)

+ (NSArray *)fetchWithLightController:(LightController *)lightObject inManageObjectContext:(NSManagedObjectContext *)context;

+ (BulbChannel *)getWithWithName:(NSString *)name withLightController:(LightController *)lightObject inManageObjectContext:(NSManagedObjectContext *)context;

+ (BulbChannel *)addWithName:(NSString *)name withLightController:(LightController *)light inManageObjectContext:(NSManagedObjectContext *)context;

+ (void)removeObject:(BulbChannel *)object inManageObjectContext:(NSManagedObjectContext *)context;

@end
