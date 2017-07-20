//
//  Theme+CoreDataProperties.h
//  VLCController
//
//  Created by Mojy on 2017/6/2.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "Theme+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Theme (CoreDataProperties)

+ (NSFetchRequest<Theme *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *isDefualt;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *themeName;
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
