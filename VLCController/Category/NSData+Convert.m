//
//  NSData+Convert.m
//  VLCController
//
//  Created by Mojy on 2017/6/2.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "NSData+Convert.h"

@implementation NSData (Convert)

- (NSString *)convertHexDataToString
{
    Byte *pData = (Byte *)[self bytes];
    
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (NSInteger index = 0; index < self.length; index++) {
        
        [hexString appendFormat:@"%02x", pData[index]];
    }
    
    return hexString;
}

@end
