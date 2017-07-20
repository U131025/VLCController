//
//  ColorFavorites+CoreDataProperties.m
//  VLCController
//
//  Created by Mojy on 2017/6/2.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "ColorFavorites+CoreDataProperties.h"

@implementation ColorFavorites (CoreDataProperties)

+ (NSFetchRequest<ColorFavorites *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ColorFavorites"];
}

@dynamic color;
@dynamic isCustom;
@dynamic name;
@dynamic warm;

@end
