//
//  LightControllerCommand.m
//  VLCController
//
//  Created by mojingyu on 16/1/21.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "LightControllerCommand.h"
#import "UIColor+extension.h"
#import "NSString+Extension.h"

@implementation LightControllerCommand

// 按位异或处理
+ (Byte)getVerify:(Byte *)sendData datalength:(int)length
{
    Byte verify = sendData[0];
    
    for (int i = 1; i < length; i++) {
        verify ^= sendData[i];
    }
    
    return verify;
}

+ (Byte *)getUDID
{
    NSString *udid = [SvUDIDTools UDID];
    NSData *bytes = [udid dataUsingEncoding:NSUTF8StringEncoding];
    Byte *udidByte = (Byte *)[bytes bytes];
    return udidByte;
}

+ (Byte *)converStringToByte:(NSString *)string
{
    NSData *bytes = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *byte = (Byte *)[bytes bytes];
    return byte;
}

+ (Byte *)getCurTime
{
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *time=[dateformatter stringFromDate:senddate];
    
    NSData *bytes = [time dataUsingEncoding:NSUTF8StringEncoding];
    Byte *udidByte = (Byte *)[bytes bytes];
    return udidByte;
}

+ (Byte)getDayOfWeek
{
    //获取当前的星期数
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
//    [dateformatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [dateformatter setDateFormat:@"EEEE"];
    
    NSString *time=[dateformatter stringFromDate:senddate];
    
    if ([time isEqualToString:@"Monday"]) {
        return 0x01;
    } else if ([time isEqualToString:@"Tuesday"]) {
        return 0x02;
    } else if ([time isEqualToString:@"Wednesday"]) {
        return 0x03;
    }  else if ([time isEqualToString:@"Thursday"]) {
        return 0x04;
    } else if ([time isEqualToString:@"Friday"]) {
        return 0x05;
    } else if ([time isEqualToString:@"Saturday"]) {
        return 0x06;
    } else if ([time isEqualToString:@"Sunday"]) {
        return 0x07;
    }

    return 0x00;
}

//主控蓝牙配对
+ (NSData *)pairMainControllerCommand:(NSString *)timeSp
{
    int pos = 0;
    Byte commandData[20] = {0};
    commandData[pos] = 0xCA; pos++;
    commandData[pos] = 0xC1; pos++;
    
    //ID
    long lTimeSp = (long)[timeSp longLongValue];
    commandData[pos] = (lTimeSp >> 8) & 0xff; pos++;
    commandData[pos] = (lTimeSp >> 4) & 0xff; pos++;
    commandData[pos] = lTimeSp & 0xff; pos++;
    
    //time
    Byte *timeByte = [self getCurTime];
    int index = 0;
    
    // 年 高位
    Byte hValue = timeByte[index];
    hValue = hValue  << 4;
    Byte lValue = timeByte[index+1];
    lValue = lValue & 0x0f;
    commandData[pos] = hValue + lValue; pos++; index+=2;
    
    // 年 低位
    hValue = timeByte[index]; hValue = hValue  << 4;
    lValue = timeByte[index+1]; lValue = lValue & 0x0f;
    commandData[pos] = hValue + lValue; pos++; index+=2;
    
    // 星期
    commandData[pos] = [self getDayOfWeek]; pos++;
    
    //月
    hValue = timeByte[index]; hValue = hValue  << 4;
    lValue = timeByte[index+1]; lValue = lValue & 0x0f;
    commandData[pos] = hValue + lValue; pos++; index+=2;
    //日
    hValue = timeByte[index]; hValue = hValue  << 4;
    lValue = timeByte[index+1]; lValue = lValue & 0x0f;
    commandData[pos] = hValue + lValue; pos++; index+=2;
    //时
    hValue = timeByte[index]; hValue = hValue  << 4;
    lValue = timeByte[index+1]; lValue = lValue & 0x0f;
    commandData[pos] = hValue + lValue; pos++; index+=2;
    //分
    hValue = timeByte[index]; hValue = hValue  << 4;
    lValue = timeByte[index+1]; lValue = lValue & 0x0f;
    commandData[pos] = hValue + lValue; pos++; index+=2;
    //秒
    hValue = timeByte[index]; hValue = hValue  << 4;
    lValue = timeByte[index+1]; lValue = lValue & 0x0f;
    commandData[pos] = hValue + lValue; pos++;
//    index+=2;
    
    Byte verify = [self getVerify:commandData datalength:19];
    commandData[19] = verify;
    return [[NSData alloc] initWithBytes:commandData length:20];
}
//从控制蓝牙配对
+ (NSData *)pairSlaveControllerCommand:(NSString *)timeSp
{
    int pos = 0;
    Byte commandData[20] = {0};
    commandData[pos] = 0xCB; pos++;
    commandData[pos] = 0xC1; pos++;
    
    //ID
    long lTimeSp = (long)[timeSp longLongValue];
    commandData[pos] = (lTimeSp >> 8) & 0xff; pos++;
    commandData[pos] = (lTimeSp >> 4) & 0xff; pos++;
    commandData[pos] = lTimeSp & 0xff; pos++;
    
    //time
    Byte *timeByte = [self getCurTime];
    int index = 0;
    
    // 年 高位
    Byte hValue = timeByte[index];
    hValue = hValue  << 4;
    Byte lValue = timeByte[index+1];
    lValue = lValue & 0x0f;
    commandData[pos] = hValue + lValue; pos++; index+=2;
    
    // 年 低位
    hValue = timeByte[index]; hValue = hValue  << 4;
    lValue = timeByte[index+1]; lValue = lValue & 0x0f;
    commandData[pos] = hValue + lValue; pos++; index+=2;
    //月
    hValue = timeByte[index]; hValue = hValue  << 4;
    lValue = timeByte[index+1]; lValue = lValue & 0x0f;
    commandData[pos] = hValue + lValue; pos++; index+=2;
    //日
    hValue = timeByte[index]; hValue = hValue  << 4;
    lValue = timeByte[index+1]; lValue = lValue & 0x0f;
    commandData[pos] = hValue + lValue; pos++; index+=2;
    //时
    hValue = timeByte[index]; hValue = hValue  << 4;
    lValue = timeByte[index+1]; lValue = lValue & 0x0f;
    commandData[pos] = hValue + lValue; pos++; index+=2;
    //分
    hValue = timeByte[index]; hValue = hValue  << 4;
    lValue = timeByte[index+1]; lValue = lValue & 0x0f;
    commandData[pos] = hValue + lValue; pos++; index+=2;
    //秒
    hValue = timeByte[index]; hValue = hValue  << 4;
    lValue = timeByte[index+1]; lValue = lValue & 0x0f;
    commandData[pos] = hValue + lValue; pos++;
//    index+=2;
    
    Byte verify = [self getVerify:commandData datalength:19];
    commandData[19] = verify;
    return [[NSData alloc] initWithBytes:commandData length:20];
}
//开关
+ (NSData *)turnPowerOnorOff:(BOOL)isOn
{
    int pos = 0;
    Byte commandData[20] = {0};
    commandData[pos] = 0xAB; pos++;
    
    if (isOn) {
        commandData[pos] = 0xF0; pos++;
    } else {
        commandData[pos] = 0x0F; pos++;
    }
    
    Byte verify = [self getVerify:commandData datalength:19];
    commandData[19] = verify;
    return [[NSData alloc] initWithBytes:commandData length:20];
}
//更改主题
+ (NSData *)setTheColorThemeWithChannel:(ChannelModel *)channel
{
    int pos = 0;
    Byte commandData[20] = {0};
    commandData[pos] = 0xDB; pos++;
    commandData[pos] = 0xCC; pos++;
    
    //channel id
    commandData[pos] = channel.index; pos++;
    
    //color 1
    if (channel.color) {
        commandData[pos] = (int)[UIColor redValueFromUIColor:channel.color]; pos++;
        commandData[pos] = (int)[UIColor greenValueFromUIColor:channel.color]; pos++;
        commandData[pos] = (int)[UIColor blueValueFromUIColor:channel.color]; pos++;
        
        //W1
        if (channel.warmValue) {
            commandData[pos] = [channel.warmValue hexStringConvertIntValue]; pos++;
        } else {
            commandData[pos] = 0x00; pos++;
        }
        
    }
    
    if (channel.subColor) {
        commandData[pos] = (int)[UIColor redValueFromUIColor:channel.subColor]; pos++;
        commandData[pos] = (int)[UIColor greenValueFromUIColor:channel.subColor]; pos++;
        commandData[pos] = (int)[UIColor blueValueFromUIColor:channel.subColor]; pos++;
        
        //W2
        if (channel.subWarmValue) {
            commandData[pos] = [channel.subWarmValue hexStringConvertIntValue]; pos++;
        } else {
            commandData[pos] = 0x00; pos++;
        }
    }
    
    Byte verify = [self getVerify:commandData datalength:19];
    commandData[19] = verify;
    return [[NSData alloc] initWithBytes:commandData length:20];
}

+ (NSData *)setLightScheduleOnOrOff:(BOOL)isOn
{
    int pos = 0;
    Byte commandData[20] = {0};
    commandData[pos] = 0xAB; pos++;
    commandData[pos] = 0xCD; pos++;
    
    Byte verify = [self getVerify:commandData datalength:19];
    commandData[19] = verify;
    return [[NSData alloc] initWithBytes:commandData length:20];
}
//更新计划命令
+ (NSData *)updateController:(BOOL)isSimplePlan withDayIndex:(NSInteger)dayIndex withChannel:(ChannelModel *)channel withOnTime:(NSString *)onTime withOffTime:(NSString *)offTime isPhotoCell:(BOOL)isPhotoCell
{
    int pos = 0;
    Byte commandData[20] = {0};
    commandData[pos] = 0xCA; pos++;
    
    if (isSimplePlan) {
        commandData[pos] = 0xC5; pos++;
        commandData[pos] = dayIndex; pos++;
        
    } else {
        commandData[pos] = 0xCF; pos++;
        commandData[pos] = dayIndex; pos++;
    }
    
    //TIME ON
    commandData[pos] = 0xF0; pos++;
    commandData[pos] = [[onTime substringToIndex:2] hexStringConvertIntValue]; pos++;
    commandData[pos] = [[onTime substringFromIndex:2] hexStringConvertIntValue]; pos++;
    
    //TIME OFF
    commandData[pos] = 0x0F; pos++;
    commandData[pos] = [[offTime substringToIndex:2] hexStringConvertIntValue]; pos++;
    commandData[pos] = [[offTime substringFromIndex:2] hexStringConvertIntValue]; pos++;
    
    //光控
    commandData[pos] = isPhotoCell ? 0x0F : 0xF0;
    pos++;
    
    //channel
    commandData[pos] = channel.index; pos++;
    
    //color 1
    if (channel.color) {
        commandData[pos] = (int)[UIColor redValueFromUIColor:channel.color]; pos++;
        commandData[pos] = (int)[UIColor greenValueFromUIColor:channel.color]; pos++;
        commandData[pos] = (int)[UIColor blueValueFromUIColor:channel.color]; pos++;
        
        //W1
        if (channel.warmValue) {
            commandData[pos] = [channel.warmValue hexStringConvertIntValue]; pos++;
        } else {
            commandData[pos] = 0x00; pos++;
        }
        
    }
    
    if (channel.subColor) {
        commandData[pos] = (int)[UIColor redValueFromUIColor:channel.subColor]; pos++;
        commandData[pos] = (int)[UIColor greenValueFromUIColor:channel.subColor]; pos++;
        commandData[pos] = (int)[UIColor blueValueFromUIColor:channel.subColor]; pos++;
        
        //W2
        if (channel.subWarmValue) {
            commandData[pos] = [channel.subWarmValue hexStringConvertIntValue]; pos++;
        } else {
            commandData[pos] = 0x00; pos++;
        }
    }
    
    Byte verify = [self getVerify:commandData datalength:19];
    commandData[19] = verify;
    return [[NSData alloc] initWithBytes:commandData length:20];
}

//配对灯泡
+ (NSData *)pairOrUnpairBulbs:(BOOL)isPair withTimeSp:(NSString *)timeSp
{
    int pos = 0;
    Byte commandData[20] = {0};
    commandData[pos] = 0xDB; pos++;
    
    if (isPair)
        commandData[pos] = 0xC1;
    else
        commandData[pos] = 0xC2;
    
    pos++;
    
    //ID
    long lTimeSp = (long)[timeSp longLongValue];
    commandData[pos] = (lTimeSp >> 8) & 0xff; pos++;
    commandData[pos] = (lTimeSp >> 4) & 0xff; pos++;
    commandData[pos] = lTimeSp & 0xff; pos++;

    Byte verify = [self getVerify:commandData datalength:19];
    commandData[19] = verify;
    return [[NSData alloc] initWithBytes:commandData length:20];
}

//更换通道
+ (NSData *)changeBulbChannel:(ChannelModel *)channel changedChannelIndex:(NSInteger)changedIndex;
{
    int pos = 0;
    Byte commandData[20] = {0};
    commandData[pos] = 0xDB; pos++;
    commandData[pos] = 0xBB; pos++;
    
    //通道 被更改
    commandData[pos] = changedIndex; pos++;
    
    //通道 更改
    commandData[pos] = channel.index; pos++;
    
    @try {
        //color 1
        if (channel.color) {
            commandData[pos] = (int)[UIColor redValueFromUIColor:channel.color]; pos++;
            commandData[pos] = (int)[UIColor greenValueFromUIColor:channel.color]; pos++;
            commandData[pos] = (int)[UIColor blueValueFromUIColor:channel.color]; pos++;
            
            //W1
            commandData[pos] = (int)[UIColor blueValueFromUIColor:channel.color]; pos++;
        }
        
        if (channel.subColor) {
            commandData[pos] = (int)[UIColor redValueFromUIColor:channel.subColor]; pos++;
            commandData[pos] = (int)[UIColor greenValueFromUIColor:channel.subColor]; pos++;
            commandData[pos] = (int)[UIColor blueValueFromUIColor:channel.subColor]; pos++;
            
            //W2
            commandData[pos] = (int)[UIColor blueValueFromUIColor:channel.color]; pos++;
        }
    } @catch (NSException *exception) {
        ;
    } @finally {
        ;
    }
    
    Byte verify = [self getVerify:commandData datalength:19];
    commandData[19] = verify;
    return [[NSData alloc] initWithBytes:commandData length:20];
}

//插头配对
+ (NSData *)pairWirelessPlug:(NSString *)timeSp
{
    int pos = 0;
    Byte commandData[20] = {0};
    commandData[pos] = 0xDC; pos++;
    commandData[pos] = 0xC1; pos++;
    
    //ID
    long lTimeSp = (long)[timeSp longLongValue];
    commandData[pos] = (lTimeSp >> 8) & 0xff; pos++;
    commandData[pos] = (lTimeSp >> 4) & 0xff; pos++;
    commandData[pos] = lTimeSp & 0xff; pos++;
    
    Byte verify = [self getVerify:commandData datalength:19];
    commandData[19] = verify;
    return [[NSData alloc] initWithBytes:commandData length:20];
}

//取消插头配对
+ (NSData *)unpairWirelessPlug:(NSString *)timeSp
{
    int pos = 0;
    Byte commandData[20] = {0};
    commandData[pos] = 0xDC; pos++;
    commandData[pos] = 0xFC; pos++;
    
    //ID
    long lTimeSp = (long)[timeSp longLongValue];
    commandData[pos] = (lTimeSp >> 8) & 0xff; pos++;
    commandData[pos] = (lTimeSp >> 4) & 0xff; pos++;
    commandData[pos] = lTimeSp & 0xff; pos++;
    
    Byte verify = [self getVerify:commandData datalength:19];
    commandData[19] = verify;
    return [[NSData alloc] initWithBytes:commandData length:20];
}
//结束命令
+ (NSData *)compeleteCommandOnUseSchedulePlan:(BOOL)useSchedulePlan
{
    Byte commandData[20] = {0};
    commandData[0] = 0xEE;
    
    if (!useSchedulePlan) {
        commandData[1] = 0x0F;
    } else {
        commandData[1] = 0xF0;
    }
//    for (int i = 0; i < 20; i++) {
//        commandData[i] = 0xEE;
//    }
    
    Byte verify = [self getVerify:commandData datalength:19];
    commandData[19] = verify;
    return [[NSData alloc] initWithBytes:commandData length:20];
}

//固件更新命令
+ (NSData *)updateFirmwareCommand
{
    Byte commandData[20] = {0};
    for (NSInteger index = 0; index < 20; index++) {
        commandData[index] = 0x7f;
    }
    
    return [[NSData alloc] initWithBytes:commandData length:20];
}

//文件长度
+ (NSData *)readyUpdateFirmwareCommandWithDataLen:(NSInteger)dataLen
{
    int pos = 0;
    Byte commandData[20] = {0};
    commandData[pos] = (dataLen >> 8) & 0xff; pos++;
    commandData[pos] = dataLen & 0xff; pos++;
    
    Byte verify = [self getVerify:commandData datalength:19];
    commandData[19] = verify;
    return [[NSData alloc] initWithBytes:commandData length:20];
}

//校验版本命令
+ (NSData *)checkVersionCommand:(NSString *)version
{
    version = [version lowercaseString];
    NSInteger ver = [[version stringByReplacingOccurrencesOfString:@"v" withString:@""] integerValue];
    
    int pos = 0;
    Byte commandData[20] = {0};
    commandData[pos] = 0xDF; pos++;
    commandData[pos] = ver; pos++;
    
    Byte verify = [self getVerify:commandData datalength:19];
    commandData[19] = verify;
    return [[NSData alloc] initWithBytes:commandData length:20];
}

//格式化发送字符串
+ (NSData *)formatCommand:(NSData *)data
{
    if (data.length >= 20) {
        return data;
    }
    
    Byte commandData[20] = {0};
    
    Byte *pData = (Byte *)[data bytes];
    
    for (int i = 0; i < data.length; i++) {
        commandData[i] = pData[i];
    }
    
    Byte verify = [self getVerify:commandData datalength:19];
    commandData[19] = verify;
    return [[NSData alloc] initWithBytes:commandData length:20];
}

@end
