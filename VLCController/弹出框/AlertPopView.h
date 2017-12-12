//
//  AlertPopView.h
//  VLCController
//
//  Created by mojingyu on 2017/12/12.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertPopView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *textView;

- (void)setBlockForContinue:(void (^)())continueBlock;

@end
