//
//  ConnectModel.m
//  VLCController
//
//  Created by Mojy on 2017/6/1.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "ConnectModel.h"

@implementation ConnectModel

- (instancetype)initWithString:(NSString *)string
{
    NSRange rang = [string rangeOfString:@"#"];
    
    if (rang.location != NSNotFound) {
        
        NSString *deviceName = [string substringToIndex:rang.location];
        NSString *password = [string substringFromIndex:rang.location+1];
        
        if (deviceName && password) {
            
            self = [super init];
            self.deviceName = deviceName;
            self.password = password;
            return self;
        }
    }
    
    return nil;
}

@end
