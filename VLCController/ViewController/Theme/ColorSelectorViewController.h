//
//  ColorSelectorViewController.h
//  VLCController
//
//  Created by mojingyu on 16/9/11.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "BaseViewController.h"

@interface ColorSelectorViewController : BaseViewController

@property (nonatomic, copy) void (^onSelecteColorBlock)(UIColor *color, UIColor *showColor, NSString *colorName);

@end
