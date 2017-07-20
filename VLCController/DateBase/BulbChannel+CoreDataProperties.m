//
//  BulbChannel+CoreDataProperties.m
//  VLCController
//
//  Created by Mojy on 2017/6/2.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "BulbChannel+CoreDataProperties.h"

@implementation BulbChannel (CoreDataProperties)

+ (NSFetchRequest<BulbChannel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"BulbChannel"];
}

@dynamic index;
@dynamic name;
@dynamic lightController;

@end
