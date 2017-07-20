//
//  Channel+CoreDataProperties.h
//  VLCController
//
//  Created by Mojy on 2017/6/2.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "Channel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Channel (CoreDataProperties)

+ (NSFetchRequest<Channel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *colorName;
@property (nullable, nonatomic, copy) NSString *colorType;
@property (nullable, nonatomic, copy) NSString *firstColorValue;
@property (nullable, nonatomic, copy) NSNumber *index;
@property (nullable, nonatomic, copy) NSNumber *isCustom;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *secondColorValue;
@property (nullable, nonatomic, copy) NSString *showColor;
@property (nullable, nonatomic, copy) NSString *showSubColor;
@property (nullable, nonatomic, copy) NSString *subColorType;
@property (nullable, nonatomic, copy) NSString *subWarmVlaue;
@property (nullable, nonatomic, copy) NSString *warmValue;
@property (nullable, nonatomic, retain) Theme *myTheme;

@end

NS_ASSUME_NONNULL_END
