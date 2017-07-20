//
//  NSArray+SHYUtil.m
//  BluetoothBox
//
//  Created by mojingyu on 2017/4/9.
//  Copyright © 2017年 com.huang. All rights reserved.
//

#import "NSArray+SHYUtil.h"

@implementation NSArray (SHYUtil)

- (id)objectAtIndexCheck:(NSUInteger)index
{
    if (index >= [self count]) {
        return nil;
    }
    
    id value = [self objectAtIndex:index];
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}

@end
