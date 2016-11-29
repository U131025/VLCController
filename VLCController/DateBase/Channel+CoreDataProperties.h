//
//  Channel+CoreDataProperties.h
//  VLCController
//
//  Created by mojingyu on 16/9/14.
//  Copyright © 2016年 Mojy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Channel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Channel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *colorName;
@property (nullable, nonatomic, retain) NSString *colorType;
@property (nullable, nonatomic, retain) NSString *firstColorValue;
@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSNumber *isCustom;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *secondColorValue;
@property (nullable, nonatomic, retain) NSString *subColorType;
@property (nullable, nonatomic, retain) NSString *subWarmVlaue;
@property (nullable, nonatomic, retain) NSString *warmValue;
@property (nullable, nonatomic, retain) NSString *showColor;
@property (nullable, nonatomic, retain) NSString *showSubColor;
@property (nullable, nonatomic, retain) Theme *myTheme;

@end

NS_ASSUME_NONNULL_END
