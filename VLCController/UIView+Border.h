//
//  UIView+Border.h
//  lidaguoji
//
//  Created by Mojy on 2017/11/22.
//  Copyright © 2017年 wangning. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BorderLineType) {
    BorderLineTypeTop,
    BorderLineTypeLeft,
    BorderLineTypeRight,
    BorderLineTypeBottom,
};

@interface UIView (Border)

+ (void)addBorderToView:(UIView *)view color:(UIColor *)color;

+ (void)addLineToView:(UIView *)view color:(UIColor *)color direction:(BorderLineType)direction;

@end
