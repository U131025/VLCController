//
//  AlertPopView.h
//  VLCController
//
//  Created by mojingyu on 2017/12/12.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCHLinkTextView.h"
#import "CCHLinkTextViewDelegate.h"
#import "CCHLinkGestureRecognizer.h"

@interface AlertPopView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CCHLinkTextView *textView;

- (void)setBlockForContinue:(void (^)())continueBlock;

- (void)setTitle:(NSString *)title content:(NSString *)content linkString:(NSString *)linkString;

- (void)show;

- (void)hide;
@end
