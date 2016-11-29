//
//  TipMessageView.h
//  VLCController
//
//  Created by mojingyu on 16/1/27.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TipMessageView : UIView

@property (nonatomic, strong) NSString *headTitleText;
@property (nonatomic, strong) NSString *tiptilteText;
@property (nonatomic, strong) NSString *tipDetailText;

@property (nonatomic, strong) NSString *okButtonContent;
@property (nonatomic, strong) NSString *cancelButtonContent;
@property (nonatomic, assign) BOOL isCancelIcon;


@property (nonatomic, copy) void (^okActionBlock)();
@property (nonatomic, copy) void (^cancelActionBlock)();

- (void)show;

@end
