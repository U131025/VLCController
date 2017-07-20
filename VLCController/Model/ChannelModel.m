//
//  ChannelModel.m
//  VLCController
//
//  Created by mojingyu on 16/1/19.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ChannelModel.h"
#import "UIColor+extension.h"

@implementation ChannelModel

- (id)initWithBulbChannel:(BulbChannel *)bulbChannel
{
    self = [super init];
    if (self) {
        self.index = [bulbChannel.index integerValue];
        self.name = bulbChannel.name;
    }
    return self;
}

- (id)initWithChannel:(Channel *)channel
{
    self = [super init];
    if (self) {
        self.index = [channel.index integerValue];
        self.name = channel.name;
        self.color = [UIColor getColor:channel.firstColorValue];
        self.subColor = [UIColor getColor:channel.secondColorValue];
        self.colorName = channel.colorName;
        self.warmValue = channel.warmValue;
        self.subWarmValue = channel.subWarmVlaue;
        
        self.colorType = channel.colorType;
        self.subColorType = channel.subColorType;
        self.showColor = [UIColor getColor:channel.showColor];;
        self.showSubColor = [UIColor getColor:channel.showSubColor];
        
        self.isCustomColor = YES;
    }
    return self;
}
@end
