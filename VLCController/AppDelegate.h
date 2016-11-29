//
//  AppDelegate.h
//  VLCController
//
//  Created by mojingyu on 16/1/7.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

typedef enum
{
    Schedule_Simple,
    Schedule_Custom,
}ScheduleType;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, assign) ScheduleType scheduleType;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

