//
//  ScheduleModel.m
//  VLCController
//
//  Created by mojingyu on 16/3/8.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ScheduleModel.h"

@implementation ScheduleItemModel

- (id)initWithScheduleItem:(ScheduleItem *)item
{
    self = [super init];
    if (self) {
        self.isSelected = [item.isSelected boolValue];
        self.name = item.name;
        self.date = item.date;
        self.themeName = item.themeName;
        self.date = item.date;
    }
    return self;
}

@end

@implementation ScheduleModel

- (NSMutableArray *)items
{
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}
@end
