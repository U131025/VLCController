//
//  DropDownListView.h
//  VLCController
//
//  Created by mojingyu on 16/1/15.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropDownListView : UIView

@property (nonatomic, assign) CGPoint pt;   //起始点
@property (nonatomic, assign) CGFloat width;    //宽度
@property (nonatomic, assign) NSInteger rowHeight;
@property (nonatomic, assign) NSInteger maxShowRowCount;
@property (nonatomic, assign) NSInteger minShowRowCount;
@property (nonatomic, copy) void (^selectActionBlock)(LightControllerModel *light);

- (void)showDropListaWithData:(NSArray *)listData;

@end
