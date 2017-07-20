//
//  Channel+Fetch.h
//  VLCController
//
//  Created by mojingyu on 16/1/29.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "Channel+CoreDataClass.h"

@interface Channel (Fetch)

+ (ChannelModel *)convertToModel:(Channel *)channel;

+ (NSArray *)getChannelWithTheme:(Theme *)themeObject inManageObjectContext:(NSManagedObjectContext *)context;

+ (Channel *)getChannelWithName:(NSString *)channelName withTheme:(Theme *)themeObject inManageObjectContext:(NSManagedObjectContext *)context;

+ (Channel *)addChannelWithName:(NSString *)channelName withTheme:(Theme *)themeObject inManageObjectContext:(NSManagedObjectContext *)context;

+ (void)removeChannel:(Channel *)channelObject inManageObjectContext:(NSManagedObjectContext *)context;

@end
