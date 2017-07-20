//
//  TableViewConfig.m
//  LedController
//
//  Created by Mojy on 2017/6/14.
//  Copyright © 2017年 com.ledController.app. All rights reserved.
//

#import "LTTableViewConfig.h"
#import "NSArray+SHYUtil.h"

typedef NS_ENUM(NSInteger, LTTableViewStyleType) {
    LTTableViewStyleTypeSingleSection,
    LTTableViewStyleTypeMultieSection,
};



@interface LTTableViewConfig ()

@property (nonatomic, copy) NSString* cellIdentigier;
@property (nonatomic, copy) TableViewCellConfigureBlock configureCellBlock;
@property (nonatomic, copy) TableViewCellDidSelectBlock didSelectBlock;
@property (nonatomic, copy) TableViewCellHeightBlock heightBlock;
@property (nonatomic, copy) TableViewCellRegisterClassBlock registerBlock;
@property (nonatomic, copy) TableViewItemsOfRowInSectionBlock itemOfRowBlock;


@property (nonatomic, assign) LTTableViewStyleType styleType;

@end

@implementation LTTableViewConfig

- (id)initWithItems:(NSArray *)aItems
     cellIdentifier:(NSString *)aIdentifier
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock
    cellHeightBlock:(TableViewCellHeightBlock)aHeightBlock
     didSelectBlock:(TableViewCellDidSelectBlock)aDidSelectBlock
{
    self = [super init];
    if (self) {
        self.items = aItems;
        self.cellIdentigier = aIdentifier;
        self.configureCellBlock = aConfigureCellBlock;
        self.heightBlock = aHeightBlock;
        self.didSelectBlock = aDidSelectBlock;
        self.styleType = LTTableViewStyleTypeSingleSection;
    }
    return self;
}

/**
 初始化，cell为纯代码方式
 
 @param aItems 数据源
 @param aRegisterBlock 注册Cell的Block，可以实现多个Cell样式，为nil则为默认的样式
 @param aConfigureCellBlock Cell赋值的Block
 @param aHeightBlock Cell高度Block
 @param aDidSelectBlock Cell 选中Block
 @return 实例
 */
- (id)initWithItems:(NSArray *)aItems
  registerCellBlock:(TableViewCellRegisterClassBlock)aRegisterBlock
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock
    cellHeightBlock:(TableViewCellHeightBlock)aHeightBlock
     didSelectBlock:(TableViewCellDidSelectBlock)aDidSelectBlock
{
    self = [super init];
    if (self) {
        self.items = aItems;
        self.registerBlock = aRegisterBlock;
        self.configureCellBlock = aConfigureCellBlock;
        self.heightBlock = aHeightBlock;
        self.didSelectBlock = aDidSelectBlock;
        self.cellSpace = 10;
        self.styleType = LTTableViewStyleTypeSingleSection;
    }
    return self;
}


/**
 多个Section样式

 @param items 数据源
 @param registBlock 注册Cell的Block，可以实现多个Cell样式，为nil则为默认的样式
 @param numberBlock Row的数量
 @param configureCellBlock Cell赋值的Block
 @param heightBlock Cell高度Block
 @param didSelectBlock 选中Block
 @return 实例
 */
- (id)initWithSections:(NSArray *)sections
      registerCell:(TableViewCellRegisterClassBlock)registBlock
       itemsOfRow:(TableViewItemsOfRowInSectionBlock)itemsOfRowBlock
configureCellBlock:(TableViewCellConfigureBlock)configureCellBlock
   cellHeightBlock:(TableViewCellHeightBlock)heightBlock
    didSelectBlock:(TableViewCellDidSelectBlock)didSelectBlock
{
    self = [super init];
    if (self) {
        self.items = sections;
        self.registerBlock = registBlock;
        self.configureCellBlock = configureCellBlock;
        self.heightBlock = heightBlock;
        self.didSelectBlock = didSelectBlock;
        self.itemOfRowBlock = itemsOfRowBlock;

        self.styleType = LTTableViewStyleTypeMultieSection;
    }
    return self;
}

- (void)handleTableViewDataSourceAndDelegate:(UITableView *)aTableView
{
    aTableView.delegate = self;
    aTableView.dataSource = self;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath
{
    //多个Section的时候
    if (self.styleType == LTTableViewStyleTypeMultieSection) {
        if (self.itemOfRowBlock) {
            id sectionItem = [self itemAtSection:indexPath.section];
            NSArray *items = self.itemOfRowBlock(indexPath.section, sectionItem);
            if (items) {
                return [items objectAtIndexCheck:indexPath.row];
            }
        }
    }
    
    //单个section时
    return [self.items objectAtIndexCheck:indexPath.row];
}

- (id)itemAtSection:(NSInteger)section
{
    //只有在多个Section的时候使用
    if (self.styleType == LTTableViewStyleTypeMultieSection) {
        return [self.items objectAtIndexCheck:section];
    }
    
    return nil;
}

#pragma mark - Block 创建视图
/**
 设置Section的Header和Footer
 
 @param headerViewBlock Header
 @param footerViewBlock Footer
 */
- (void)setBlockForSecitonHeaderView:(TableViewHeaderOrFooterViewBlock)headerViewBlock sectionFooterView:(TableViewHeaderOrFooterViewBlock)footerViewBlock
{
    self.sectionHeaderViewBlock = headerViewBlock;
    self.sectionFooterViewBlock = footerViewBlock;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.styleType == LTTableViewStyleTypeMultieSection) {
        return self.items.count;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.styleType == LTTableViewStyleTypeMultieSection) {
        
        if (self.itemOfRowBlock) {
            id sectionItem = [self itemAtSection:section];
            NSArray *items = self.itemOfRowBlock(section, sectionItem);
            if (items) {
                return items.count;
            }
        }
        
        return 1;
    }
    
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 44;
    id item = [self itemAtIndexPath:indexPath];
    if (self.heightBlock) {
        cellHeight = self.heightBlock(indexPath, item);
    }
    else {
        return [UITableViewCell getCellHeightWitCustomObj:item indexPath:indexPath];
    }
    
    cellHeight += self.cellSpace;
    
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.sectionHeaderViewBlock) {
        UIView *headerView = self.sectionHeaderViewBlock(section, [self itemAtSection:section]);
        if (headerView) {
            return CGRectGetHeight(headerView.frame);
        }
    }
    
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.sectionFooterViewBlock) {
        UIView *footerView = self.sectionFooterViewBlock(section, [self itemAtSection:section]);
        if (footerView) {
            return CGRectGetHeight(footerView.frame);
        }
    }
    
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self itemAtIndexPath:indexPath];
    
    UITableViewCell *cell;
    if (self.registerBlock) {
        cell = self.registerBlock(tableView, indexPath, item);
    }
    else {

        static NSString *cellIdentifier = @"Cell Identifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentigier ? self.cellIdentigier : cellIdentifier];
        if (!cell) {
            //使用xib的方式
            if (self.cellIdentigier) {
                [UITableViewCell registerTabelView:tableView nibIdentifier:self.cellIdentigier];
                cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentigier];
            }
            else {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    //绘制
//    if (self.styleType == LTTableViewStyleTypeMultieSection) {
//        if (self.itemOfRowBlock) {
//            id sectionItem = [self itemAtSection:indexPath.section];
//            NSArray *items = self.itemOfRowBlock(indexPath.section, sectionItem);
//            if (items) {
//                item = [items objectAtIndexCheck:indexPath.row];
//            }
//        }
//    }
//    else {
//        item = [self itemAtIndexPath:indexPath];
//    }
//    
//    if (self.configureCellBlock) {
//        self.configureCellBlock(indexPath,cell,item);
//    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item;
    if (self.styleType == LTTableViewStyleTypeMultieSection) {
        if (self.itemOfRowBlock) {
            id sectionItem = [self itemAtSection:indexPath.section];
            NSArray *items = self.itemOfRowBlock(indexPath.section, sectionItem);
            if (items) {
                item = [items objectAtIndexCheck:indexPath.row];
            }
        }
    }
    else {
        item = [self itemAtIndexPath:indexPath];
    }
    
    if (self.configureCellBlock) {
        self.configureCellBlock(indexPath,cell,item);
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self itemAtIndexPath:indexPath];
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.didSelectBlock) {
        self.didSelectBlock(indexPath, cell, item);
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.sectionHeaderViewBlock) {
        
        id item = [self itemAtSection:section];
        return self.sectionHeaderViewBlock(section, item);
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.sectionFooterViewBlock) {
        id item = [self itemAtSection:section];
        return self.sectionFooterViewBlock(section, item);
    }
    
    return nil;
}

@end
