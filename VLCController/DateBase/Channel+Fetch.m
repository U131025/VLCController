//
//  Channel+Fetch.m
//  VLCController
//
//  Created by mojingyu on 16/1/29.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "Channel+Fetch.h"
#import "UIColor+extension.h"

@implementation Channel (Fetch)

+ (ChannelModel *)convertToModel:(Channel *)channel
{
    ChannelModel *model = [[ChannelModel alloc] init];
    model.index = [channel.index integerValue];
    model.name = channel.name;
    model.color = [UIColor getColor:channel.firstColorValue];
    model.subColor = [UIColor getColor:channel.secondColorValue];
    model.colorName = channel.colorName;
    model.warmValue = channel.warmValue;
    model.subWarmValue = channel.subWarmVlaue;
    
    return model;
}

+ (NSArray *)getChannelWithTheme:(Theme *)themeObject inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!themeObject) return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Channel" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"myTheme == %@", themeObject];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = NULL;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    if (array) {
        //进行排序
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSNumber *strObj1 = (NSNumber *)obj1;
            NSNumber *strObj2 = (NSNumber *)obj2;
            
            @try {
                NSInteger selfInteger = [strObj1 integerValue];
                NSInteger otherInteger = [strObj2 integerValue];
                if (selfInteger == otherInteger) {
                    return NSOrderedSame;
                } else if (selfInteger > otherInteger) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }
            @catch (NSException *exception) {
                return NSOrderedSame;
            }
            
        }];
        
        NSArray *newArray = [array sortedArrayUsingDescriptors:@[sortDescriptor]];
//        NSLog(@"\n ============\n %@ \n=================\n", newArray);
        return newArray;
    }
    
    return array;
    
}

+ (Channel *)getChannelWithName:(NSString *)channelName withTheme:(Theme *)themeObject inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!channelName || !themeObject) {
        return nil;
    }
    
    Channel *finder = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Channel" inManagedObjectContext:context]];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@ AND myTheme == %@", channelName, themeObject];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = NULL;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    if (array && (array.count > 0)) {
        finder = [array objectAtIndex:0];
    }
    
    return finder;
}

+ (Channel *)addChannelWithName:(NSString *)channelName withTheme:(Theme *)themeObject inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!themeObject) {
        return nil;
    }
    
    Channel *newChannel = [self getChannelWithName:channelName withTheme:themeObject inManageObjectContext:context];
    if (!newChannel) {
        newChannel = [NSEntityDescription insertNewObjectForEntityForName:@"Channel" inManagedObjectContext:context];
    }
    
    newChannel.name = channelName;
    newChannel.myTheme = themeObject;
    
    return newChannel;
}

+ (void)removeChannel:(Channel *)channelObject inManageObjectContext:(NSManagedObjectContext *)context
{
    if (!channelObject) {
        return;
    }
    
    [context deleteObject:channelObject];
}

@end
