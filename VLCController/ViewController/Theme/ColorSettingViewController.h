//
//  ColorSettingViewController.h
//  VLCController
//
//  Created by mojingyu on 16/9/11.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ColorSettingViewController : BaseViewController

@property (nonatomic, strong) UIColor *currentColor;
@property (nonatomic, strong) UIColor *templateColor;

- (instancetype)initWithColor:(UIColor *)color withSettingColor:(UIColor *)settingColor;

@property (nonatomic, copy) void (^onSelecteColorBlock)(UIColor *color, NSString *warmValue);

@end
