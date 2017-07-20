//
//  TImePickerView.h
//  VLCController
//
//  Created by mojingyu on 16/3/8.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimePickerView : UIView

@property (nonatomic, copy) void (^doneActionBlock)(NSString *result);

- (void)show;

@end
