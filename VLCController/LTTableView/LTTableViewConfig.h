//
//  TableViewConfig.h
//  LedController
//
//  Created by Mojy on 2017/6/14.
//  Copyright © 2017年 com.ledController.app. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UITableViewCell+Extension.h"

//Block定义
typedef void (^TableViewCellConfigureBlock)(NSIndexPath* indexPath, id cell, id item);
typedef void (^TableViewCellDidSelectBlock)(NSIndexPath* indexPath, id cell, id item);
typedef CGFloat (^TableViewCellHeightBlock)(NSIndexPath* indexPath, id item);
typedef CGFloat (^TableViewSectionHeightBlock)(NSInteger section);
typedef NSInteger (^TableViewNumberOfSectionBlock)(NSInteger section);
typedef UIView *(^TableViewHeaderOrFooterViewBlock)(NSInteger section, id sectionItem);
typedef NSArray *(^TableViewItemsOfRowInSectionBlock)(NSInteger section, id sectionItem);


//不同类型的Cell
typedef UITableViewCell *(^TableViewCellRegisterClassBlock)(UITableView *tableView, NSIndexPath* indexPath, id item);


///////////////  LTTableViewConfig ////////////////////

@interface LTTableViewConfig : NSObject<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray *items; //通过setItems，更新数据源

//section Header and Footer
//@property (nonatomic, copy) TableViewSectionHeightBlock sectionHeaderHeightBlock;
//@property (nonatomic, copy) TableViewSectionHeightBlock sectionFooterHeightBlock;

@property (nonatomic, copy) TableViewHeaderOrFooterViewBlock sectionHeaderViewBlock;
@property (nonatomic, copy) TableViewHeaderOrFooterViewBlock sectionFooterViewBlock;


@property (nonatomic, assign) NSInteger cellSpace;

/**
 初始化，cell使用xib的方式

 @param aItems 数据源
 @param aIdentifier 标识(xib的identifier)
 @param aConfigureCellBlock Cell赋值的Block
 @param aHeightBlock Cell高度Block
 @param aDidSelectBlock Cell 选中Block
 @return 实例
 */
- (id)initWithItems:(NSArray *)aItems
     cellIdentifier:(NSString *)aIdentifier
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock
    cellHeightBlock:(TableViewCellHeightBlock)aHeightBlock
     didSelectBlock:(TableViewCellDidSelectBlock)aDidSelectBlock;


/**
 初始化 cell为纯代码方式，
 对应的Cell需要实现- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier

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
     didSelectBlock:(TableViewCellDidSelectBlock)aDidSelectBlock;

/**
 初始化 多个Section样式
 
 @param items 数据源
 @param registBlock 注册Cell的Block，可以实现多个Cell样式，为nil则为默认的样式
 @param itemsOfRowBlock Item Of Row In Section
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
     didSelectBlock:(TableViewCellDidSelectBlock)didSelectBlock;

/**
 设置TableView的委托

 @param aTableView 需要设置的TableView
 */
- (void)handleTableViewDataSourceAndDelegate:(UITableView*)aTableView;


/**
 设置Section的Header和Footer

 @param headerViewBlock Header
 @param footerViewBlock Footer
 */
- (void)setBlockForSecitonHeaderView:(TableViewHeaderOrFooterViewBlock)headerViewBlock sectionFooterView:(TableViewHeaderOrFooterViewBlock)footerViewBlock;

/**
 列数据

 @param indexPath 索引
 @return 数据
 */
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
