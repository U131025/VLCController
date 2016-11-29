//
//  ColorFavorites+CoreDataProperties.h
//  VLCController
//
//  Created by mojingyu on 16/3/10.
//  Copyright © 2016年 Mojy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ColorFavorites.h"

NS_ASSUME_NONNULL_BEGIN

@interface ColorFavorites (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *color;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *warm;
@property (nullable, nonatomic, retain) NSNumber *isCustom;

@end

NS_ASSUME_NONNULL_END
