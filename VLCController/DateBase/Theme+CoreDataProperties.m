//
//  Theme+CoreDataProperties.m
//  VLCController
//
//  Created by Mojy on 2017/6/2.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "Theme+CoreDataProperties.h"

@implementation Theme (CoreDataProperties)

+ (NSFetchRequest<Theme *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Theme"];
}

@dynamic isDefualt;
@dynamic name;
@dynamic themeName;
@dynamic channels;
@dynamic lightController;

@end
