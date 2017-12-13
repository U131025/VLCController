//
//  UIView+PopAnimation.h
//  YiDianQian
//
//  Created by Mojy on 2017/11/23.
//  Copyright © 2017年 YiDianQian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PopAnimation)

- (void)animationAlert;

- (void)showAnimated;

- (void)closeAnimated:(BOOL)animated;
- (void)closeAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

- (void)showAnimationWithShowPosition:(CGRect)showPosition hiddenPosition:(CGRect)hidePosition;

- (void)hideAnimationWithShowPosition:(CGRect)showPosition hiddenPosition:(CGRect)hidePosition completion:(void (^)(BOOL finished))completion;

@end
