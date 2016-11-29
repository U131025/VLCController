//
//  NSString+CustomCompare.m
//  VLCController
//
//  Created by mojingyu on 16/3/8.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "NSString+CustomCompare.h"

@implementation NSString (CustomCompare)

- (NSComparisonResult)customCompare:(NSString *)other
{
    NSInteger selfInteger = [self integerValue];
    NSInteger otherInteger = [other integerValue];
    if (selfInteger == otherInteger) {
        return NSOrderedSame;
    } else if (selfInteger > otherInteger) {
        return NSOrderedDescending;
    } else {
        return NSOrderedAscending;
    }

}

@end
