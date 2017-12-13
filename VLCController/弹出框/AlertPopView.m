//
//  AlertPopView.m
//  VLCController
//
//  Created by mojingyu on 2017/12/12.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "AlertPopView.h"
#import "UIView+PopAnimation.h"
#import "UIView+Border.h"

#define ItemCellHeight 44
#define BodyWidth 350
#define CellSpace 15

@interface AlertPopView()<CCHLinkTextViewDelegate>

@property (nonatomic, strong) UIView *bodyView;
@property (nonatomic, copy) void (^continueBlock)(void);

@end


@implementation AlertPopView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = RGBAlphaColor(0, 0, 0, 0.5);
        
        self.bodyView = [[UIView alloc] init];
        self.bodyView.layer.cornerRadius = 15;
        self.bodyView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bodyView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = Font(15);
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor blackColor];
        [self.bodyView addSubview:self.titleLabel];
        
        self.textView = [[CCHLinkTextView alloc] init];
        self.textView.linkDelegate = self;
        self.textView.linkTextAttributes = @{NSForegroundColorAttributeName : [UIColor blueColor]};
        self.textView.linkCornerRadius = 4.0f;
        
//        self.textView.editable = NO;   // 非编辑状态下才可以点击Url
        [self.bodyView addSubview:self.textView];
        
        UIButton *cancelButton = [[UIButton alloc] init];
        cancelButton.titleLabel.font = Font(15);
        [cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [self.bodyView addSubview:cancelButton];
        
        UIButton *continueButton = [[UIButton alloc] init];
        continueButton.titleLabel.font = Font(15);
        [continueButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [continueButton setTitle:@"CONTINUE" forState:UIControlStateNormal];
        [continueButton addTarget:self action:@selector(continueAction) forControlEvents:UIControlEventTouchUpInside];
        [self.bodyView addSubview:continueButton];
        
        //layout
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bodyView).offset(15);
            make.right.equalTo(self.bodyView).offset(-15);
            make.top.equalTo(self.titleLabel.mas_bottom);
            make.bottom.equalTo(cancelButton.mas_top);
        }];
        
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(self.bodyView);
            make.width.equalTo(self.bodyView).multipliedBy(0.5);
            make.height.mas_equalTo(ItemCellHeight);
        }];
        
        [continueButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(self.bodyView);
            make.width.equalTo(self.bodyView).multipliedBy(0.5);
            make.height.equalTo(cancelButton);
        }];
        
        [UIView addLineToView:cancelButton color:[UIColor blueColor] direction:BorderLineTypeTop];
        [UIView addLineToView:cancelButton color:[UIColor blueColor] direction:BorderLineTypeRight];
        [UIView addLineToView:continueButton color:[UIColor blueColor] direction:BorderLineTypeTop];
    }
    return self;
}

- (void)cancelAction
{
    [self hide];
}

- (void)continueAction
{
    [self cancelAction];
    
    if (self.continueBlock) {
        self.continueBlock();
    }
}

- (void)setBlockForContinue:(void (^)())continueBlock
{
    self.continueBlock = continueBlock;
}

- (void)setTitle:(NSString *)title content:(NSString *)content linkString:(NSString *)linkString
{
    self.titleLabel.text = title;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6;//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,content.length)];
    
    if (linkString) {
        NSRange rang = [content rangeOfString:linkString options:NSLiteralSearch];
        [attributedString addAttribute:CCHLinkAttributeName value:linkString range:rang];
    }
    
    self.textView.attributedText = attributedString;
    
    //计算高度
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(BodyWidth - 30, MAXFLOAT)];
    CGSize contentSize = [self.textView sizeThatFits:CGSizeMake(BodyWidth - 30, MAXFLOAT)];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bodyView).offset(CellSpace);
        make.left.equalTo(self.bodyView).offset(15);
        make.right.equalTo(self.bodyView).offset(-15);
        make.height.mas_equalTo(titleSize.height);
    }];
    
    [self.bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(BodyWidth);
        make.height.mas_equalTo(CellSpace * 2 + ItemCellHeight + titleSize.height + contentSize.height);
    }];
}

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    if (value) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *linkString = [NSString stringWithFormat:@"http://%@", value];
            
            if (iOS_Version_10) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkString] options:@{} completionHandler:nil];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkString]];
            }
        });
    }
}

- (void)show
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    self.center = window.center;
    [window addSubview:self];
    self.frame = window.bounds;
    
    [self.bodyView showAnimated];
}

- (void)hide
{
    [self removeFromSuperview];
}

@end
