//
//  DateFuncation.h
//  ElectronicScales
//
//  Created by mojingyu on 15/11/11.
//  Copyright © 2015年 Mojy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateFuncation : NSObject

+ (int)CaculateAgeWithBirthday:(NSString *)birthday;

+ (int)CaculateDateIntervalWithFromDate:(NSString *)fromDate withToDate:(NSString*)toDate;

+ (NSDate *)getNextDate:(NSDate *)date;

+ (NSString *)getNowDate;

+ (NSString *)convertDateToString:(NSDate *)date;

//获取时间戳
+ (NSString *)getTimeSp;

@end
