//
//  SingletonMacro.h
//  CBExtension
//
//  Created by ly on 13-8-1.
//  Copyright (c) 2013年 Lei Yan. All rights reserved.
//

#ifndef ProjectStructure_Extension_SingletonMacro_h
#define ProjectStructure_Extension_SingletonMacro_h


#define DECLARE_SINGLETON(CLASS_NAME) \
+ (CLASS_NAME *)sharedInstance;


#define SYNTHESIZE_SINGLETONE_FOR_CLASS(CLASS_NAME) \
+ (CLASS_NAME *)sharedInstance\
{\
    static CLASS_NAME *__##CLASS_NAME##_instance = nil;\
\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        __##CLASS_NAME##_instance = [[CLASS_NAME alloc] init];\
    [__##CLASS_NAME##_instance loadData];\
    });\
    return __##CLASS_NAME##_instance;\
}

#endif
