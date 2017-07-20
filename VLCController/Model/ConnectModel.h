//
//  ConnectModel.h
//  VLCController
//
//  Created by Mojy on 2017/6/1.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectModel : NSObject

@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *passwordNew;

- (instancetype)initWithString:(NSString *)string;

@end
