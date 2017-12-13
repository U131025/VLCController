//
//  UIView+PopAnimation.m
//  YiDianQian
//
//  Created by Mojy on 2017/11/23.
//  Copyright © 2017年 YiDianQian. All rights reserved.
//

#import "UIView+PopAnimation.h"
#import "POP.h"

@implementation UIView (PopAnimation)

- (void)animationAlert
{
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.layer addAnimation:popAnimation forKey:nil];
}

- (void)showAnimated
{
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

- (void)closeAnimated:(BOOL)animated
{
    [self closeAnimated:animated completion:nil];
}

- (void)closeAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.3 animations:^{
                self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                if (completion) {
                    completion(finished);
                }
            }];
        }];
    }
    else {
        [self removeFromSuperview];
    }
}

- (void)showAnimationWithShowPosition:(CGRect)showPosition hiddenPosition:(CGRect)hidePosition
{
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    positionAnimation.fromValue = [NSValue valueWithCGRect:hidePosition];
    positionAnimation.toValue = [NSValue valueWithCGRect:showPosition];
    positionAnimation.springBounciness = 15.0f;
    positionAnimation.springSpeed = 20.0f;
    [self pop_addAnimation:positionAnimation forKey:@"frameAnimation"];
}

- (void)hideAnimationWithShowPosition:(CGRect)showPosition hiddenPosition:(CGRect)hidePosition completion:(void (^)(BOOL finished))completion
{
    POPBasicAnimation *positionAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    positionAnimation.fromValue = [NSValue valueWithCGRect:showPosition];
    positionAnimation.toValue = [NSValue valueWithCGRect:hidePosition];
    [self pop_addAnimation:positionAnimation forKey:@"frameAnimation"];
    
    [positionAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}


@end
