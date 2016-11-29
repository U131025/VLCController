//
//  ScheduleModel.h
//  VLCController
//
//  Created by mojingyu on 16/3/8.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScheduleItem.h"

#define SimpleSchedule @"SimpleSchedule"
#define CustomSchedule @"CustomSchedule"
#define ScheduleDateFormat @"MMMM dd,yyyy"
#define ScheduleTimeFormat @"hh:mm a"

@interface ScheduleItemModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *themeName;
@property (nonatomic, assign) BOOL isSelected;

- (id)initWithScheduleItem:(ScheduleItem *)item;

@end

@interface ScheduleModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL isCustomSchedule;
@property (nonatomic, copy) NSString *timeOn;
@property (nonatomic, copy) NSString *timeOff;
@property (nonatomic, assign) BOOL isPhotoCell;
@property (nonatomic, strong) NSMutableArray *items; // of schedule Item

@end
