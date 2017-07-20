//
//  TextTableViewCell.m
//  VLCController
//
//  Created by mojingyu on 16/1/18.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "TextTableViewCell.h"
#import "NSString+Extension.h"
#import "myUILabel.h"

@interface TextTableViewCell()

@property (nonatomic, strong) UILabel *topLineLabel;
@property (nonatomic, strong) UILabel *bottomLineLabel;
@property (nonatomic, strong) myUILabel *titleLabel;
@property (nonatomic, strong) myUILabel *subTitleLable;

@end

@implementation TextTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.frame];
    backgroundView.backgroundColor = RGBAlphaColor(255,255,255,0.3);
    self.selectedBackgroundView = backgroundView;
}

- (void)setIsTopLine:(BOOL)isTopLine
{
    if (isTopLine) {
        _topLineLabel = [[UILabel alloc] init];
        _topLineLabel.backgroundColor = WhiteColor;
        _topLineLabel.frame = (CGRect){0, 0, ScreenWidth, 1};
        [self.contentView addSubview:_topLineLabel];
    } else if (_topLineLabel) {
        [_topLineLabel removeFromSuperview];
    }
}

- (void)setIsBottomLine:(BOOL)isBottomLine
{
    if (isBottomLine) {
        _bottomLineLabel = [[UILabel alloc] init];
        _bottomLineLabel.backgroundColor = WhiteColor;
        _bottomLineLabel.frame = (CGRect){0, 59, ScreenWidth, 1};
        [self.contentView addSubview:_bottomLineLabel];
    } else if (_bottomLineLabel) {
        [_bottomLineLabel removeFromSuperview];
    }
}

- (void)setTitleText:(NSString *)titleText
{
    CGSize titleSize = [titleText sizeWithFont:Font(16) maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    if (!_titleLabel) {
        _titleLabel = [[myUILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.verticalAlignment = VerticalAlignmentMiddle;
        _titleLabel.font = Font(16);
        _titleLabel.textColor = WhiteColor;
    }
    _titleLabel.text = titleText;
    _titleLabel.frame = (CGRect){40, 0, titleSize.width, 60};
    
    [self.contentView addSubview:_titleLabel];
}

- (void)setSubTitleText:(NSString *)subTitleText
{
    CGSize subTitleSize = [subTitleText sizeWithFont:Font(16) maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    if (!_subTitleLable) {
        _subTitleLable = [[myUILabel alloc] init];
        _subTitleLable.textColor = WhiteColor;
        _subTitleLable.textAlignment = NSTextAlignmentCenter;
        _subTitleLable.verticalAlignment = VerticalAlignmentMiddle;
        _subTitleLable.font = Font(12);
    }
    
    _subTitleLable.frame = (CGRect){CGRectGetMaxX(_titleLabel.frame)+5, 5, subTitleSize.width, CGRectGetHeight(_titleLabel.frame)};
    _subTitleLable.text = subTitleText;
    
    [self.contentView addSubview:_subTitleLable];
}

- (void)setIsArrow:(BOOL)isArrow
{
    if (isArrow) {
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth- 40, 10, 20, 40)];
        arrowImageView.image = [UIImage imageNamed:@"arrow"];
        [self.contentView addSubview:arrowImageView];
    }
    
}

@end
