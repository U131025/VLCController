//
//  ColorButton.h
//  VLCController
//
//  Created by mojingyu on 16/9/13.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColorButton;

@protocol ColorButtonDelegate <NSObject>

- (void)colorButtonLongPressAction:(ColorButton *)sender;

@end

@interface ColorButton : UIControl

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, weak) id<ColorButtonDelegate> delegate;

@end
