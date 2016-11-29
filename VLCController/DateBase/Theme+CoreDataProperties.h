//
//  Theme+CoreDataProperties.h
//  VLCController
//
//  Created by mojingyu on 16/3/24.
//  Copyright © 2016年 Mojy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Theme.h"

NS_ASSUME_NONNULL_BEGIN

@interface Theme (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *themeName;
@property (nullable, nonatomic, retain) NSNumber *isDefualt;
@property (nullable, nonatomic, retain) NSSet<Channel *> *channels;
@property (nullable, nonatomic, retain) LightController *lightController;

@end

@interface Theme (CoreDataGeneratedAccessors)

- (void)addChannelsObject:(Channel *)value;
- (void)removeChannelsObject:(Channel *)value;
- (void)addChannels:(NSSet<Channel *> *)values;
- (void)removeChannels:(NSSet<Channel *> *)values;

@end

NS_ASSUME_NONNULL_END
