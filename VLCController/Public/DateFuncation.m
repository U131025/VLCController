//
//  DateFuncation.m
//  ElectronicScales
//
//  Created by mojingyu on 15/11/11.
//  Copyright © 2015年 Mojy. All rights reserved.
//

#import "DateFuncation.h"

@implementation DateFuncation

+ (int)CaculateAgeWithBirthday:(NSString *)birthday
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *birthDate = [dateFormatter dateFromString:birthday];
    NSTimeInterval dateDiff = [birthDate timeIntervalSinceNow];
    int age = trunc(dateDiff / (60*60*24)) / 365;
    return -age;
}

// 计算两日期间隔天数
+ (int)CaculateDateIntervalWithFromDate:(NSString *)fromDate withToDate:(NSString*)toDate
{
    NSTimeZone *localTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:localTimeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    fromDate = [NSString stringWithFormat:@"%@ 00:00:00", fromDate];
    NSDate *from = [dateFormatter dateFromString:fromDate];
    NSLog(@"%@", from);

    toDate = [NSString stringWithFormat:@"%@ 00:00:00", toDate];
    NSDate *to = [dateFormatter dateFromString:toDate];
    
    NSTimeInterval dateDiff = [to timeIntervalSinceDate:from];
    
    int day = dateDiff / (3600 * 24);
    
    return day;
    
}

+ (NSDate *)getNextDate:(NSDate *)date
{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSTimeZone *localTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
//    [dateFormatter setTimeZone:localTimeZone];
    
    NSTimeInterval interval = 3600 * 24;    // one day
    NSDate *tomorrow = [date dateByAddingTimeInterval:interval];
    return tomorrow;

}


+ (NSString *)getNowDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [NSDate date];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)convertDateToString:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormatter stringFromDate:date];
}

//获取当前系统的时间戳
+ (NSString *)getTimeSp
{    
    long time;
    NSDate *fromdate=[NSDate date];
    time=(long)[fromdate timeIntervalSince1970];
    
    return [NSString stringWithFormat:@"%ld", time];
}


@end
