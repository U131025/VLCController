//
//  UIView+Border.m
//  lidaguoji
//
//  Created by Mojy on 2017/11/22.
//  Copyright © 2017年 wangning. All rights reserved.
//

#import "UIView+Border.h"

@implementation UIView (Border)

+ (void)addBorderToView:(UIView *)view color:(UIColor *)color
{
    [self addLineToView:view color:color direction:BorderLineTypeTop];
    [self addLineToView:view color:color direction:BorderLineTypeBottom];
    [self addLineToView:view color:color direction:BorderLineTypeRight];
}

+ (void)addLineToView:(UIView *)view color:(UIColor *)color direction:(BorderLineType)direction
{
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = color;
    [view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (direction == BorderLineTypeTop) {
            make.left.right.top.equalTo(view);
            make.height.mas_equalTo(0.5);
        }
        else if (direction == BorderLineTypeLeft) {
            make.top.bottom.left.equalTo(view);
            make.width.mas_equalTo(0.5);
        }
        else if (direction == BorderLineTypeRight) {
            make.top.bottom.right.equalTo(view);
            make.width.mas_equalTo(0.5);
        }
        else {
            make.left.right.bottom.equalTo(view);
            make.height.mas_equalTo(0.5);
        }
    }];
}

@end
