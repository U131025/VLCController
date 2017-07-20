//
//  UITableViewCell+Extension.m
//  LedController
//
//  Created by Mojy on 2017/6/14.
//  Copyright © 2017年 com.ledController.app. All rights reserved.
//

#import "UITableViewCell+Extension.h"

@implementation UITableViewCell (Extension)

//注册cell xib方式
+ (void)registerTabelView:(UITableView*)aTable
            nibIdentifier:(NSString*)identifier
{
    [aTable registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
}

/**
 注册并创建

 @param aTable UITableView
 @param indexPath 索引
 @return 返回Cell
 */
+ (instancetype)registerTabelView:(UITableView *)aTable forIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = NSStringFromClass([self class]);
    UITableViewCell *cell = [aTable dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

//载入数据
- (void)configure:(UITableViewCell*)aCell
        custimObj:(id)obj
        indexPath:(NSIndexPath*)indexPath
{
    
}

//根据数据源计算cell高度 默认返回44.0f
+ (CGFloat)getCellHeightWitCustomObj:(id)obj
                           indexPath:(NSIndexPath*)indexPath
{
    return 44.0f;
}

@end
