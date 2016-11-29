//
//  ColorOptionsViewController.h
//  VLCController
//
//  Created by mojingyu on 16/1/27.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "BaseViewController.h"


@interface ColorOptionsViewController : BaseViewController

@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) NSString *colorString;

@property (nonatomic, copy) void (^onSaveColorBlock)(UIColor *selectedColor);
@property (nonatomic, copy) void (^onSelecteSpecialColorBlock)(UIColor *color, NSString *warmValue);

@end
