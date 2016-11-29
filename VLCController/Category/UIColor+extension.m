//
//  UIColor+extension.m
//  VLCController
//
//  Created by mojingyu on 16/1/28.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "UIColor+extension.h"

////////////////////////////

@implementation UIColor (extension)

+ (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

+ (UIColor*) colorWithHex:(NSInteger)hexValue
{
    return [UIColor colorWithHex:hexValue alpha:1.0];
}

+ (UIColor *)getColor:(NSString*)hexColor
{
    if (!hexColor || [hexColor isEqualToString:@""]) {
        return nil;
    }
    
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f)green:(float)(green / 255.0f) blue:(float)(blue / 255.0f)alpha:1.0f];
}

+ (NSString *) hexFromUIColor: (UIColor*) color
{
    if (!color) return nil;
    
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0]
                                green:components[0]
                                 blue:components[0]
                                alpha:components[1]];
    }
    
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"FFFFFF"];
    }
    
    NSString *hexValue = [NSString stringWithFormat:@"%02x%02x%02x", (int)((CGColorGetComponents(color.CGColor))[0]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[1]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
    
    MyLog(@"%@", hexValue);
    return hexValue;
}

+ (CGFloat)redValueFromUIColor:(UIColor *)color
{
    return ((CGColorGetComponents(color.CGColor))[0]*255.0);
}
+ (CGFloat)greenValueFromUIColor:(UIColor*)color
{
    return ((CGColorGetComponents(color.CGColor))[1]*255.0);
}
+ (CGFloat)blueValueFromUIColor:(UIColor *)color
{
    return ((CGColorGetComponents(color.CGColor))[2]*255.0);
}

@end

