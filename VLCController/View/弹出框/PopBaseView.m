//
//  PopBaseView.m
//  VLCController
//
//  Created by mojingyu on 16/2/10.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "PopBaseView.h"

@implementation PopBaseView


- (void)show
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    self.center = window.center;
    [window addSubview:self];
}

@end
