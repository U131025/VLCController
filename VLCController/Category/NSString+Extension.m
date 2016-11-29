//
//  NSString+Extension.m
//  VLCController
//
//  Created by mojingyu on 16/1/14.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)
//返回字符串所占用的尺寸.
-(CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

//十六进制 0xff 字符串转换为值
- (unsigned long)hexStringConvertIntValue
{
    //先以16为参数告诉strtoul字符串参数表示16进制数字，然后使用0x%X转为数字类型
    unsigned long hexValue = strtoul([self UTF8String],0,16);
    return hexValue;
}


@end
