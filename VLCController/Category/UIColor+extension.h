//
//  UIColor+extension.h
//  VLCController
//
//  Created by mojingyu on 16/1/28.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (extension)

+ (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;
+ (UIColor*) colorWithHex:(NSInteger)hexValue;
+ (NSString *) hexFromUIColor: (UIColor*) color;
+ (UIColor *)getColor:(NSString*)hexColor;

+ (CGFloat)redValueFromUIColor:(UIColor *)color;
+ (CGFloat)greenValueFromUIColor:(UIColor*)color;
+ (CGFloat)blueValueFromUIColor:(UIColor *)color;

@end
