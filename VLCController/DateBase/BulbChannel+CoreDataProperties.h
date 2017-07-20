//
//  BulbChannel+CoreDataProperties.h
//  VLCController
//
//  Created by Mojy on 2017/6/2.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "BulbChannel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BulbChannel (CoreDataProperties)

+ (NSFetchRequest<BulbChannel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *index;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) LightController *lightController;

@end

NS_ASSUME_NONNULL_END
