//
//  Channel+CoreDataProperties.m
//  VLCController
//
//  Created by Mojy on 2017/6/2.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "Channel+CoreDataProperties.h"

@implementation Channel (CoreDataProperties)

+ (NSFetchRequest<Channel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Channel"];
}

@dynamic colorName;
@dynamic colorType;
@dynamic firstColorValue;
@dynamic index;
@dynamic isCustom;
@dynamic name;
@dynamic secondColorValue;
@dynamic showColor;
@dynamic showSubColor;
@dynamic subColorType;
@dynamic subWarmVlaue;
@dynamic warmValue;
@dynamic myTheme;

@end
