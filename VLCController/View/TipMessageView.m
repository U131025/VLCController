//
//  TipMessageView.m
//  VLCController
//
//  Created by mojingyu on 16/1/27.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "TipMessageView.h"
#import "NSString+Extension.h"

@interface TipMessageView()

@property (nonatomic, strong) myUILabel *headerTitleLabel;

@property (nonatomic, strong) UITextView *detailTextView ;
@property (nonatomic, strong) UIButton *okButotn;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation TipMessageView

- (void)setHeadTitleText:(NSString *)headTitleText
{
    self.headerTitleLabel.text = headTitleText;
}

- (id)init
{
    self = [super init];
    if (self) {
        //
        self.frame = (CGRect){0, 0, ScreenWidth, ScreenHeight};
        self.backgroundColor = [UIColor clearColor];
        
        //背景
        UIImageView *backgroundImageView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
        backgroundImageView.frame = self.frame;
        [self addSubview:backgroundImageView];
        
        //标题
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, NavBarHeight)];
        headerView.backgroundColor = RGBAlphaColor(255, 255, 255, 0.8);
        [self addSubview:headerView];
        
        _headerTitleLabel = [[myUILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, CGRectGetHeight(headerView.frame)-13)];
        _headerTitleLabel.textAlignment = NSTextAlignmentCenter;
        _headerTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        _headerTitleLabel.verticalAlignment = VerticalAlignmentBottom;
        [headerView addSubview:_headerTitleLabel];
        
        
    }
    return self;
}

- (void)setupUI
{
    //布局
    CGSize detailSize = [_tipDetailText sizeWithFont:Font(14) maxSize:CGSizeMake(ScreenWidth-100, MAXFLOAT)];
    UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(50, CGRectGetMidY(self.frame)-detailSize.height-20, ScreenWidth-100, detailSize.height+10)];
    detailTextView.backgroundColor = [UIColor clearColor];
    detailTextView.text = _tipDetailText;
    detailTextView.textAlignment = NSTextAlignmentCenter;
    detailTextView.font = Font(14);
    detailTextView.textColor = WhiteColor;
    detailTextView.userInteractionEnabled = NO;
    [self addSubview:detailTextView];
    
    //title
    UILabel *tipTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, CGRectGetMinY(detailTextView.frame)-50, ScreenWidth-100, 50)];
    tipTitleLabel.backgroundColor = [UIColor clearColor];
    tipTitleLabel.text = _tiptilteText;
    tipTitleLabel.textAlignment = NSTextAlignmentCenter;
    tipTitleLabel.font = Font(20);
    tipTitleLabel.textColor = WhiteColor;
    [self addSubview:tipTitleLabel];
    
    //button
    if (_okButtonContent) {
        _okButotn = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMidY(self.frame)+20, ScreenWidth-100, 60)];
        _okButotn.layer.borderColor = WhiteColor.CGColor;
        _okButotn.layer.borderWidth = 1;
        [_okButotn setTitle:_okButtonContent forState:UIControlStateNormal];
        [_okButotn addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_okButotn];
    }
    
    if (_cancelButtonContent) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(_okButotn.frame)+30, CGRectGetWidth(_okButotn.frame), CGRectGetHeight(_okButotn.frame))];
        _cancelButton.layer.borderWidth = 1;
        _cancelButton.layer.borderColor = WhiteColor.CGColor;
        [_cancelButton setTitle:_cancelButtonContent forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
        
        if (self.isCancelIcon) {
            UIButton *cancelIcon = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMinY(_cancelButton.frame), 60, CGRectGetHeight(_cancelButton.frame))];
            [cancelIcon setTitle:@"✕" forState:UIControlStateNormal];
            cancelIcon.titleLabel.font = Font(30);
            [cancelIcon setTitleColor:WhiteColor forState:UIControlStateNormal];
            [cancelIcon addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:cancelIcon];
            
            UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cancelIcon.frame), CGRectGetMinY(cancelIcon.frame), 1, CGRectGetHeight(cancelIcon.frame))];
            line.backgroundColor = WhiteColor;
            [self addSubview:line];
        }
    }

}

#pragma mark Show
- (void)show
{
    [self setupUI];
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    self.center = window.center;
    [window addSubview:self];
}

- (void)okAction
{
    if (self.okActionBlock) {
        self.okActionBlock();
    }
    [self removeFromSuperview];
}

- (void)cancelAction
{
    if (self.cancelActionBlock) {
        self.cancelActionBlock();
    }
    [self removeFromSuperview];
}

@end
