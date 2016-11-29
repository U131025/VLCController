//
//  EditThemeViewController.h
//  VLCController
//
//  Created by mojingyu on 16/1/19.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "BaseViewController.h"
#import "Theme+Fetch.h"

typedef enum
{
    EditType_New,
    EditType_Modify,
    
}ThemeEditType;

@interface EditThemeViewController : BaseViewController

@property (nonatomic, strong) Theme *theme;
@property (nonatomic, assign) ThemeEditType editType;

@end
