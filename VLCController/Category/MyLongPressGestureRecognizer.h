//
//  MyLongPressGestureRecognizer.h
//  VLCController
//
//  Created by mojingyu on 16/3/28.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyLongPressGestureRecognizer : UILongPressGestureRecognizer

@property (nonatomic, assign) NSInteger tag;

- (id)initWithTarget:(id)target action:(SEL)action tag:(NSInteger)tag;

@end
