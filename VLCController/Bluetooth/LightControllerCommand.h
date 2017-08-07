//
//  LightControllerCommand.h
//  VLCController
//
//  Created by mojingyu on 16/1/21.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThemeModel.h"
#import "ChannelModel.h"

@interface LightControllerCommand : NSObject

+ (NSData *)pairMainControllerCommand:(NSString *)timeSp;
+ (NSData *)pairSlaveControllerCommand:(NSString *)timeSp;

+ (NSData *)turnPowerOnorOff:(BOOL)isOn;

+ (NSData *)setTheColorThemeWithChannel:(ChannelModel *)channel;
+ (NSData *)setLightScheduleOnOrOff:(BOOL)isOn;

//更新计划命令
+ (NSData *)updateController:(BOOL)isSimplePlan withDayIndex:(NSInteger)dayIndex withChannel:(ChannelModel *)channel withOnTime:(NSString *)onTime withOffTime:(NSString *)offTime isPhotoCell:(BOOL)isPhotoCell;

//配对或取消配对灯泡
+ (NSData *)pairOrUnpairBulbs:(BOOL)isPair withTimeSp:(NSString *)timeSp;

//更换通道
+ (NSData *)changeBulbChannel:(ChannelModel *)channel changedChannelIndex:(NSInteger)changedIndex;

//配对
+ (NSData *)pairWirelessPlug:(NSString *)timeSp;
+ (NSData *)unpairWirelessPlug:(NSString *)timeSp;

//结束命令
+ (NSData *)compeleteCommandOnUseSchedulePlan:(BOOL)useSchedulePlan;

//字节处理
+ (Byte)getVerify:(Byte *)sendData datalength:(int)length;

//固件更新命令
+ (NSData *)updateFirmwareCommand;

//文件长度
+ (NSData *)readyUpdateFirmwareCommandWithDataLen:(NSInteger)dataLen;

//校验版本命令
+ (NSData *)checkVersionCommand:(NSString *)version;

//格式化发送字符串
+ (NSData *)formatCommand:(NSData *)data;

@end
