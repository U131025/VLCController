//
//  BulbChannel+CoreDataProperties.h
//  VLCController
//
//  Created by mojingyu on 16/3/7.
//  Copyright © 2016年 Mojy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BulbChannel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BulbChannel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) LightController *lightController;

@end

NS_ASSUME_NONNULL_END
