//
//  MyComBoxView.m
//  VLCController
//
//  Created by mojingyu on 16/1/15.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "MyComBoxView.h"

@interface MyComBoxView()

@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIButton *comboxButton;

@property (nonatomic, assign) BOOL isExpand;
@end

@implementation MyComBoxView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.layer.borderColor = WhiteColor.CGColor;
//        self.layer.borderWidth = 1;
        _enable = YES;
        _isExpand = NO;
        
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)-30, CGRectGetHeight(frame)/2 - 10, 20, 20)];
        _arrowImageView.image = [UIImage imageNamed:@"downArrow"];
        [self addSubview:_arrowImageView];
        
        //
//        _iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)-25, 0, 20, CGRectGetHeight(frame))];
//        _iconLabel.text = @"∨";
//        _iconLabel.textAlignment = NSTextAlignmentRight;
//        _iconLabel.font = Font(16);
//        _iconLabel.textColor = WhiteColor;
//        [self addSubview:_iconLabel];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame)-25, CGRectGetHeight(frame))];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.font = Font(12);
        _contentLabel.textColor = WhiteColor;
        _contentLabel.numberOfLines = 1;
        [self addSubview:_contentLabel];
        
        _comboxButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        _comboxButton.layer.borderColor = WhiteColor.CGColor;
        _comboxButton.layer.borderWidth = 1;
        _comboxButton.titleLabel.font = Font(12);
//        _comboxButton.backgroundColor = RGBAlphaColor(120, 120, 120, 0.6);
        [_comboxButton addTarget:self action:@selector(comboxButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_comboxButton];
        
    }
    return self;
}

- (void)setEnable:(BOOL)enable
{
    _comboxButton.enabled = enable;
    UIColor *tintColor = WhiteColor;
    if (!enable) {
        tintColor = [UIColor lightGrayColor];
    }
    
    _comboxButton.layer.borderColor = tintColor.CGColor;
    [_comboxButton setTitleColor:tintColor forState:UIControlStateNormal];
}

- (void)setContentText:(NSString *)contentText
{
    _contentLabel.text = contentText;
}

- (UIImageView *)arrowImageView
{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-25, 0, 20, CGRectGetHeight(self.frame))];
        _arrowImageView.image = [UIImage imageNamed:@"downArrow"];
        [self addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

- (void)comboxButtonClick:(UIButton *)button
{
    _isExpand = !_isExpand;
//    _iconLabel.text = _isExpand ? @"∧" :@"∨";
//    self.arrowImageView.image = _isExpand ? [UIImage imageNamed:@"downArrow"]:[UIImage imageNamed:@"downArrow"];
    
    if (_clickActionBlock) {
        _clickActionBlock(_isExpand);
    }    
}

@end
