//
//  TextFieldWithBorderView.m
//  VegetableBasket
//
//  Created by mojingyu on 15/12/21.
//  Copyright © 2015年 Mojy. All rights reserved.
//

#import "TextFieldWithBorderView.h"

@interface TextFieldWithBorderView()<UITextFieldDelegate>


@end

@implementation TextFieldWithBorderView

- (void)setShowBorder:(BOOL)showBorder
{
    if (showBorder) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = WhiteColor.CGColor;
    } else {
        self.layer.borderWidth = 0;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        //
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(frame)-20, CGRectGetHeight(frame)-20)];
        
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.font = Font(16);
        _textField.textColor = [UIColor whiteColor];
        _textField.tintColor = [UIColor whiteColor];
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//        _textField.secureTextEntry = isSecureTextEntry;
//        _textField.placeholder = placeholder;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.delegate = self;
        [self addSubview:_textField];
        
    }
    return self;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_textField resignFirstResponder];
    if (self.textFieldEndEditingBlock) {
        self.textFieldEndEditingBlock(textField);
    }
}

@end
