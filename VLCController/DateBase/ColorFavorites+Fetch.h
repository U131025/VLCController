//
//  ColorFavorites+Fetch.h
//  VLCController
//
//  Created by mojingyu on 16/3/10.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ColorFavorites+CoreDataClass.h"

@interface ColorFavorites (Fetch)

+ (ColorFavorites *)getObjectWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

+ (ColorFavorites *)addObject:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

+ (BOOL)removeObject:(ColorFavorites *)object inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)fetchObjectsInManagedObjectContext:(NSManagedObjectContext *)context;

@end
