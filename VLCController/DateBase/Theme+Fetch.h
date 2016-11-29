//
//  Theme+Fetch.h
//  VLCController
//
//  Created by mojingyu on 16/1/29.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "Theme.h"

@interface Theme (Fetch)

+ (NSArray *)fetchThemesWithLightController:(LightController *)lightObject inManageObjectContext:(NSManagedObjectContext *)context;

+ (Theme *)getThemeWithWithName:(NSString *)themeName withLightController:(LightController *)lightObject inManageObjectContext:(NSManagedObjectContext *)context;

+ (Theme *)addThemeWithName:(NSString *)themeName withLightController:(LightController *)light inManageObjectContext:(NSManagedObjectContext *)context;

+ (void)removeTheme:(Theme *)themeObject inManageObjectContext:(NSManagedObjectContext *)context;

@end
