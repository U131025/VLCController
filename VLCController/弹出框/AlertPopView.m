//
//  AlertPopView.m
//  VLCController
//
//  Created by mojingyu on 2017/12/12.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "AlertPopView.h"

#define ItemCellHeight 44

@interface AlertPopView()

@property (nonatomic, strong) UIView *bodyView;
@property (nonatomic, copy) void (^continueBlock)(void);

@end


@implementation AlertPopView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.bodyView = [[UIView alloc] init];
        self.bodyView.layer.cornerRadius = 5;
        self.bodyView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bodyView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = Font(13);
        self.titleLabel.textColor = [UIColor blackColor];
        [self.bodyView addSubview:self.titleLabel];
        
        self.textView = [[UITextView alloc] init];
        self.textView.editable = NO;   // 非编辑状态下才可以点击Url
        [self.bodyView addSubview:self.textView];
        
        UIButton *cancelButton = [[UIButton alloc] init];
        cancelButton.titleLabel.font = Font(13);
        [cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [self.bodyView addSubview:cancelButton];
        
        UIButton *continueButton = [[UIButton alloc] init];
        continueButton.titleLabel.font = Font(13);
        [continueButton setTitle:@"CONTINUE" forState:UIControlStateNormal];
        [continueButton addTarget:self action:@selector(continueAction) forControlEvents:UIControlEventTouchUpInside];
        [self.bodyView addSubview:continueButton];
        
        
        //layout
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.bodyView);
            make.height.mas_equalTo(ItemCellHeight);
        }];
        
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
        
        
    }
    return self;
}

- (void)cancelAction
{
    [self removeFromSuperview];
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

@end
