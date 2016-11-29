//
//  LightControllerCellView.m
//  VLCController
//
//  Created by mojingyu on 16/1/13.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "LightControllerCellView.h"

@interface LightControllerCellView()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIButton *arrowButton;
@end

@implementation LightControllerCellView

- (id)init
{
    self = [super init];
    if (self) {
        self.isConnected = NO;
    }
    return self;
}

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _maskView.backgroundColor = RGBAlphaColor(255, 255, 255, 0.5);
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaskAction:)];
//        tap.numberOfTapsRequired = 1;
//        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //
        _useDeleteAction = YES;
    }
    return self;
}

- (void)setLightController:(LightControllerModel *)lightController
{
    _lightController = lightController;
    
    //界面初始化
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth+80, CGRectGetHeight(self.frame))];
    
    UIImageView *icon = [[UIImageView alloc] init];
    NSInteger offsetX = 10;
    NSString *arrowImageName = @"arrow";
    if (lightController.type == Slave) {
        offsetX = 30;
        arrowImageName = @"link";   //连接
    }
    
    if (self.isConnected)
        icon.image = [UIImage imageNamed:@"icon_green"];
    else
        icon.image = [UIImage imageNamed:@"icon_red"];
    
    icon.frame = (CGRect){offsetX, (CGRectGetHeight(self.frame)-20)/2, 20, 20};
    [view addSubview:icon];
    
    offsetX = CGRectGetMaxX(icon.frame)+5;
    if (lightController.type == Slave) {
        UIImageView *subArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame)+5, (CGRectGetHeight(self.frame)-20)/2, 20, 20)];
        subArrowImageView.image = [UIImage imageNamed:@"subArrow"];
        [view addSubview:subArrowImageView];
        offsetX = CGRectGetMaxX(subArrowImageView.frame)+5;
    }
    
    //name
    myUILabel *nameLabel = [[myUILabel alloc] initWithFrame:CGRectMake(offsetX, 0, ScreenWidth, CGRectGetHeight(self.frame))];
    nameLabel.text = lightController.name;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.verticalAlignment = VerticalAlignmentMiddle;
    nameLabel.font = Font(16);
    nameLabel.textColor = WhiteColor;
    [self addSubview:nameLabel];
    
    //arrow
//    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:arrowImageName]];
//    if (lightController.type != Slave)
//        arrow.frame = (CGRect){ScreenWidth-40, 10, 20, 40};
//    else
//        arrow.frame = (CGRect){ScreenWidth-40, 10, 20, 20};
//    [view addSubview:arrow];
    
    _arrowButton = [[UIButton alloc] init];
    if (lightController.type != Slave) {
        _arrowButton.frame = (CGRect){ScreenWidth-40, 10, 20, 40};
    } else {
        _arrowButton.frame = (CGRect){ScreenWidth-40, 10, 20, 20};
    }
    
    [_arrowButton setImage:[UIImage imageNamed:arrowImageName] forState:UIControlStateNormal];
    [_arrowButton addTarget:self action:@selector(arrowClickAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_arrowButton];
    
    
    //删除按钮
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth, 0, 80, CGRectGetHeight(self.frame))];
    deleteButton.layer.borderColor = WhiteColor.CGColor;
    deleteButton.layer.borderWidth = 1;
    deleteButton.backgroundColor = RedColor;
    [deleteButton setTitle:@"✕" forState:UIControlStateNormal];
    [deleteButton setTitleColor:WhiteColor forState:UIControlStateNormal];
    deleteButton.titleLabel.font = Font(18);
    [deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:deleteButton];
    
    //手势
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapRecognizer];
    
    if (self.useDeleteAction) {
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self addGestureRecognizer:swipeLeft];
        
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [self addGestureRecognizer:swipeRight];
    }
 
    _backgroundView = view;
    [self addSubview:view];
}

- (void)deleteButtonClick
{
    if (self.deleteActionBlock) {
        self.deleteActionBlock(self.lightController);
//        self.deleteActionBlock = nil;
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if (self.tapActionBlock) {
        self.tapActionBlock(self.lightController);
//        self.tapActionBlock = nil;
    }
}

- (void)swipeAction:(UISwipeGestureRecognizer *)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        
        if (self.showDeleteButtonActionBlock) {
            self.showDeleteButtonActionBlock();
//            self.showDeleteButtonActionBlock = nil;
        }
        
        [self.backgroundView addSubview:self.maskView];
        [self.arrowButton setHidden:YES];
        
        //移动视图，现实删除按钮
        if (CGRectGetMinX(self.backgroundView.frame) < 0) {
            return;
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        
        CGPoint pt = self.backgroundView.center;
        pt.x -= 80;
        [self.backgroundView setCenter:pt];
        [UIView commitAnimations];
        
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
      
        if (self.hideDeleteButtonActionBlock) {
            self.hideDeleteButtonActionBlock();
        }
        [self setOriginalPosition];
    }
}

// 设置为初始位置
- (void)setOriginalPosition
{
    [self.maskView removeFromSuperview];
    [self.arrowButton setHidden:NO];
    
    if (CGRectGetMinX(self.backgroundView.frame) < 0) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        
        CGPoint pt = self.backgroundView.center;
        pt.x += 80;
        [self.backgroundView setCenter:pt];
        [UIView commitAnimations];
    }
}

- (void)arrowClickAction
{
    if (self.arrowClickActionBlock) {
        self.arrowClickActionBlock(self.lightController);
    }
}

@end
