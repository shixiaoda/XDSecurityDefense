//
//  XDSecurityDefenseManager.m
//  Pods
//
//  Created by 施孝达 on 2018/6/9.
//

#import "XDSecurityDefenseManager.h"
#import <objc/runtime.h>

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr, "%s:%d　\t%s\n", [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif

@implementation XDSecurityDefenseManager

#pragma mark - public

+ (void)initWithClassPrefix:(NSArray <NSString *> *)classPrefixArray ignoreFunctions:(NSArray <NSString *>*)functions; {
    static XDSecurityDefenseManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [manager generate];
    });
}

- (NSSet *)allClassName {
    NSMutableSet *allClassName = [NSMutableSet set];
    unsigned int outCount;
    Class *classes = objc_copyClassList(&outCount);
    for (int i = 0; i < outCount; i++) {
        Class clazz = classes[i];
        NSString *className = NSStringFromClass(clazz);
//        NSLog(@"当前项目中全部 class: %@", className);
        [allClassName addObject:className];
    }
    free(classes);
    return allClassName;
}

- (NSSet *)customClassNames {
    NSMutableSet *customClassName = [NSMutableSet set];
    unsigned int classNamesCount = 0;
    // 用 executablePath 获取当前 app image
    NSString *appImage = [NSBundle mainBundle].executablePath;
    // objc_copyClassNamesForImage 获取到的是 image 下的类，直接排除了系统的类
    const char **classNames = objc_copyClassNamesForImage([appImage UTF8String], &classNamesCount);
    if (classNames) {
        for (unsigned int i = 0; i < classNamesCount; i++) {
            const char *className = classNames[i];
            NSString *classNameString = [NSString stringWithUTF8String:className];
            [customClassName addObject:classNameString];
        }
        free(classNames);
    }
    return customClassName;
}

- (NSSet *)systemClassNames {
    NSMutableSet *systemClassNames = [self allClassName].mutableCopy;
    NSSet *customClassNames = [self customClassNames];
    [systemClassNames minusSet:customClassNames];
    return systemClassNames;
}

- (NSSet *)methodNameListWithClasses:(NSSet <NSString *>*)classNames {
    NSMutableSet *methodNameList = [NSMutableSet set];
    [classNames enumerateObjectsUsingBlock:^(NSString * _Nonnull classNameString, BOOL * _Nonnull stop) {
        unsigned int methodCount = 0;
        Class className = NSClassFromString(classNameString);
        Method *methodList = class_copyMethodList(className, &methodCount);
        for (int i = 0; i < methodCount; i++) {
            Method method = methodList[i];
            SEL mName = method_getName(method);
            NSString *methodName = NSStringFromSelector(mName);
//            NSLog(@"instance method[%d] ---- %@", i, methodName);
            [methodNameList addObject:methodName];
        }
        free(methodList);
    }];
    return methodNameList;
}

- (NSSet *)methodNameFragment:(NSSet <NSString *>*)methodNameList
{
    NSMutableSet *methodNameFragment = [NSMutableSet set];
    [methodNameList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        NSArray <NSString *>*fragment = [obj componentsSeparatedByString:@":"];
        [fragment enumerateObjectsUsingBlock:^(NSString * _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj2 containsString:@":"] && ![obj2 hasPrefix:@"."]) {
                [methodNameFragment addObject:obj2];
            }
        }];
    }];
    return methodNameFragment;
}

- (NSSet *)propertyListWithClass:(NSString *)classNameString {
    NSMutableSet *propertyList = [NSMutableSet set];
    Class className = NSClassFromString(classNameString);
    unsigned int methodCount = 0;
    Ivar * ivars = class_copyIvarList(className, &methodCount);
    for (int i = 0; i < methodCount; i ++) {
        Ivar ivar = ivars[i];
        const char * name = ivar_getName(ivar);
        NSString *ivarName = [NSString stringWithUTF8String:name];
        while ([ivarName hasPrefix:@"_"]) {
            ivarName = [ivarName substringFromIndex:1];
        }
//        NSLog(@"ivar[%d]  %@", i, ivarName);
        [propertyList addObject:ivarName];
        [propertyList addObject:[NSString stringWithFormat:@"set%@%@",[[ivarName substringToIndex:1] uppercaseString] ,[ivarName substringFromIndex:1]]];
    }
    free(ivars);
    return propertyList;
}

- (NSSet *)protocalMethodListWithClass:(NSString *)classNameString {
    NSMutableSet *protocalMethodList = [NSMutableSet set];
    Class className = NSClassFromString(classNameString);
    unsigned int methodCount = 0;
    __unsafe_unretained Protocol **protocolList = class_copyProtocolList(className, &methodCount);
    for (int i = 0; i < methodCount; i++) {
        Protocol *protocal = protocolList[i];
        const char *pName = protocol_getName(protocal);
//        NSLog(@"protocol[%d] ---- %@", i, [NSString stringWithUTF8String:pName]);
        
        unsigned int protocolMethodCount = 0;
        struct objc_method_description * methodList = protocol_copyMethodDescriptionList(protocal, NO, YES, &protocolMethodCount);
        for (int i = 0; i < protocolMethodCount; i++) {
            struct objc_method_description method = methodList[i];
            NSString *protocolMethodName = NSStringFromSelector(method.name);
            [protocalMethodList addObject:protocolMethodName];
        }
        free(methodList);
        methodList = protocol_copyMethodDescriptionList(protocal, YES, YES, &protocolMethodCount);
        for (int i = 0; i < protocolMethodCount; i++) {
            struct objc_method_description method = methodList[i];
            NSString *protocolMethodName = NSStringFromSelector(method.name);
            [protocalMethodList addObject:protocolMethodName];
        }
    }
    free(protocolList);
    return protocalMethodList;
}

- (BOOL)superClass:(Class)class respondsToSelector:(SEL)sel
{
    Class supClass = class_getSuperclass(class);
    BOOL bTespondsToSelector= NO;
    while (supClass != nil) {
        if (class_respondsToSelector(supClass,sel)) {
            bTespondsToSelector = YES;
            supClass = nil;
        } else {
            supClass = class_getSuperclass(supClass);
        }
    }
    return bTespondsToSelector;
}

- (void)generate {
    NSSet *systemClassNames = [self systemClassNames];
    NSSet *systemMethodList = [self methodNameFragment:[self methodNameListWithClasses:systemClassNames]];
    
    NSSet *customClassNames = [self customClassNames];
//    NSSet *customMethodNameList = [self methodNameListWithClasses:customClassNames];
    __block NSSet <NSString *>*funcList = [NSMutableSet set];
    [customClassNames enumerateObjectsUsingBlock:^(NSString* className, BOOL * _Nonnull stop) {
        NSMutableSet *customMethodNameList = [self methodNameFragment:[self methodNameListWithClasses:[NSSet setWithObject:className]]].mutableCopy;
        NSSet *propertyList = [self methodNameFragment:[self propertyListWithClass:className]];
        NSSet *protocalMethodList = [self methodNameFragment:[self protocalMethodListWithClass:className]];
        
        
        [customMethodNameList minusSet:propertyList];
        [customMethodNameList minusSet:protocalMethodList];
        [customMethodNameList minusSet:systemMethodList];
//        NSLog(@"funcList : %@",customMethodNameList);
        funcList = [funcList setByAddingObjectsFromSet:customMethodNameList];
    }];
    
    NSArray *paths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *homePath = [paths objectAtIndex:0];
    NSString *filePath = [homePath stringByAppendingPathComponent:@"func.list"];
    NSLog(@"path = %@",filePath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) //如果不存在
    {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    
    [fileHandle seekToEndOfFile];
    
    [funcList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *data = [obj stringByAppendingString:@"\n"];
        NSData* stringData  = [data dataUsingEncoding:NSUTF8StringEncoding];
        [fileHandle writeData:stringData]; //追加写入数据
    }];
    
    [fileHandle closeFile];
}

@end
