//
//  MyComBoxView.h
//  VLCController
//
//  Created by mojingyu on 16/1/15.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyComBoxView : UIView

@property (nonatomic, strong) NSString *contentText;
@property (nonatomic, assign) BOOL enable;

@property (nonatomic, copy) void (^clickActionBlock)(BOOL isExpand);

@end
