//
//  TextFieldWithBorderView.h
//  VegetableBasket
//
//  Created by mojingyu on 15/12/21.
//  Copyright © 2015年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldWithBorderView : UIView

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, copy) void (^textFieldEndEditingBlock)(UITextField *textField);
@property (nonatomic, assign) BOOL showBorder;

@end
