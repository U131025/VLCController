//
//  NSArray+SHYUtil.h
//  BluetoothBox
//
//  Created by mojingyu on 2017/4/9.
//  Copyright © 2017年 com.huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (SHYUtil)

/*!
 @method objectAtIndexCheck:
 @abstract 检查是否越界和NSNull如果是返回nil
 @result 返回对象
 */
- (id)objectAtIndexCheck:(NSUInteger)index;

@end
