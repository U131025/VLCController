//
//  ColorButton.m
//  VLCController
//
//  Created by mojingyu on 16/9/13.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ColorButton.h"

@interface ColorButton()

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation ColorButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = self.width / 2;
        self.layer.borderWidth = 1;
        self.layer.borderColor = WhiteColor.CGColor;
        
        //regist longpress action
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        [self addGestureRecognizer:gesture];
    }
    return self;
}

- (void)longPressAction:(UILongPressGestureRecognizer *)gesture
{
    //需要检测手势状态，对各个状态进行不同的处理
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(colorButtonLongPressAction:)]) {
            [self.delegate colorButtonLongPressAction:self];
        }
    }
}

#pragma mark - Getter
- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = BlackColor;
        _textLabel.numberOfLines = 2;
        _textLabel.font = Font(8);
        [self addSubview:_textLabel];
    }
    return _textLabel;
}

#pragma makr - Setter
- (void)setText:(NSString *)text
{
    _text = text;
    self.textLabel.text = text;
    
}

- (void)setFont:(UIFont *)font
{
    self.textLabel.font = font;
}

- (void)setTextColor:(UIColor *)textColor
{
    self.textLabel.textColor = textColor;
}

@end
