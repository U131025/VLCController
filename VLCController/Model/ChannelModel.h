//
//  ChannelModel.h
//  VLCController
//
//  Created by mojingyu on 16/1/19.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulbChannel.h"
#import "Channel.h"

@interface ChannelModel : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *colorName;
@property (nonatomic, copy) NSString *warmValue;

@property (nonatomic, copy) NSString *colorType;
@property (nonatomic, copy) NSString *subColorType;
@property (nonatomic, strong) UIColor *showColor;
@property (nonatomic, strong) UIColor *showSubColor;

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *subColor;
@property (nonatomic, copy) NSString *subWarmValue;
@property (nonatomic, assign) BOOL isCustomColor;

- (id)initWithBulbChannel:(BulbChannel *)bulbChannel;
- (id)initWithChannel:(Channel *)channel;
@end
