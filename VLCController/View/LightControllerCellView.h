//
//  LightControllerCellView.h
//  VLCController
//
//  Created by mojingyu on 16/1/13.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LightControllerCellView : UIView

@property (nonatomic, strong) LightControllerModel *lightController;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, assign) BOOL useDeleteAction;

@property (nonatomic, copy) void (^deleteActionBlock)(LightControllerModel *lightController);
@property (nonatomic, copy) void (^tapActionBlock)(LightControllerModel *lightController);
@property (nonatomic, copy) void (^arrowClickActionBlock)(LightControllerModel *lightController);

@property (nonatomic, copy) void (^showDeleteButtonActionBlock)();
@property (nonatomic, copy) void (^hideDeleteButtonActionBlock)();

- (void)setOriginalPosition;

@end
