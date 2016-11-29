//
//  ColorDefine.h
//  VLCController
//
//  Created by mojingyu on 16/1/8.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#ifndef ColorDefine_h
#define ColorDefine_h

#define RGBAlphaColor(r, g, b, a) \
[UIColor colorWithRed:(r/255.0)\
green:(g/255.0)\
blue:(b/255.0)\
alpha:(a)]

//16进制颜色值
#define RGBFromColor(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define OpaqueRGBColor(r, g, b) RGBAlphaColor((r), (g), (b), 1.0)


#define WhiteColor  [UIColor whiteColor]
#define RedColor    [UIColor redColor]
#define GreenColor  [UIColor greenColor]
#define BlackColor  [UIColor blackColor]
#define ClearColor  [UIColor clearColor]
#define GrayColor  [UIColor grayColor]
#define AmberColor RGBFromColor(0xFFE4C4)

#endif /* ColorDefine_h */
