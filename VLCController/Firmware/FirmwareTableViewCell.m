//
//  FirmwareTableViewCell.m
//  VLCController
//
//  Created by mojingyu on 2017/7/9.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "FirmwareTableViewCell.h"
#import "FirmwareModel.h"

@interface FirmwareTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@end

@implementation FirmwareTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [UIView new];
        self.backgroundColor = [UIColor clearColor];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = Font(13);
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.textColor = WhiteColor;
        self.titleLabel.text = @"Version";
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self.mas_centerX);
        }];
        
        self.detailLabel = [[UILabel alloc] init];
        self.detailLabel.font = Font(13);
        self.detailLabel.textAlignment = NSTextAlignmentRight;
        self.detailLabel.textColor = WhiteColor;
        [self addSubview:self.detailLabel];
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_right);
            make.top.bottom.equalTo(self);
            make.right.equalTo(self).offset(-15);
        }];

        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = WhiteColor;
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(1);
        }];
        
    }
    return self;
}

- (void)configure:(UITableViewCell *)aCell custimObj:(id)obj indexPath:(NSIndexPath *)indexPath
{
    FirmwareModel *model = obj;
    if ([model isKindOfClass:[FirmwareModel class]]) {
        
        self.detailLabel.text = model.version;
    }
}

//根据数据源计算cell高度 默认返回44.0f
+ (CGFloat)getCellHeightWitCustomObj:(id)obj
                           indexPath:(NSIndexPath*)indexPath
{
    return 44;
}

@end
