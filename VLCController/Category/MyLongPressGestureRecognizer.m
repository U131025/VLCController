//
//  MyLongPressGestureRecognizer.m
//  VLCController
//
//  Created by mojingyu on 16/3/28.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "MyLongPressGestureRecognizer.h"

@implementation MyLongPressGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action tag:(NSInteger)tag
{
    self = [super initWithTarget:target action:action];
    self.tag = tag;
    return self;
}
@end
