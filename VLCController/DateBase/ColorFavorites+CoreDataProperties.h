//
//  ColorFavorites+CoreDataProperties.h
//  VLCController
//
//  Created by Mojy on 2017/6/2.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "ColorFavorites+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ColorFavorites (CoreDataProperties)

+ (NSFetchRequest<ColorFavorites *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *color;
@property (nullable, nonatomic, copy) NSNumber *isCustom;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *warm;

@end

NS_ASSUME_NONNULL_END
