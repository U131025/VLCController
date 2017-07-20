//
//  UITableViewCell+Extension.h
//  LedController
//
//  Created by Mojy on 2017/6/14.
//  Copyright © 2017年 com.ledController.app. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (Extension)

//注册cell
+ (void)registerTabelView:(UITableView*)aTable
            nibIdentifier:(NSString*)identifier;


+ (instancetype)registerTabelView:(UITableView *)aTable forIndexPath:(NSIndexPath *)indexPath;

//载入数据
- (void)configure:(UITableViewCell*)aCell
        custimObj:(id)obj
        indexPath:(NSIndexPath*)indexPath;

//根据数据源计算cell高度 默认返回44.0f
+ (CGFloat)getCellHeightWitCustomObj:(id)obj
                           indexPath:(NSIndexPath*)indexPath;

@end
