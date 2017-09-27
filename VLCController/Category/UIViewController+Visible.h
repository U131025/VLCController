//
//  UIViewController+Visible.h
//  VLCController
//
//  Created by mojingyu on 2017/9/27.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Visible)

- (UIViewController *)visibleViewControllerIfExist;

+ (UIViewController *)visibleViewController;

@end
