#import "NSPersistentStoreCoordinator+PatchRollback.h"
#import <objc/runtime.h>

#if MAC_OS_X_VERSION_MAX_ALLOWED < 1070
#define NO_ARC 1
#else
#if __has_feature(objc_arc)
#define NO_ARC 0
#else
#define NO_ARC 1
#endif
#endif


@implementation NSPersistentStoreCoordinator (PatchRollback)

+ (NSDictionary*)sqlitePragmasForRollback {
    NSDictionary* sqlitePragmas = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   @"DELETE", @"journal_mode",
                                   nil] ;
#if NO_ARC
    [sqlitePragmas autorelease] ;
#endif
    return sqlitePragmas ;
}

+ (NSDictionary*)dictionaryByAddingSqliteRollbackToDictionary:(NSDictionary*)optionsIn {
    NSMutableDictionary* mutant = [[NSMutableDictionary alloc] init] ;
    if (optionsIn) {
        [mutant addEntriesFromDictionary:optionsIn] ;
    }
    [mutant setObject:[self sqlitePragmasForRollback]
               forKey:NSSQLitePragmasOption] ;
    NSDictionary* optionsOut = [mutant copy] ;
    
#if NO_ARC
    [mutant release] ;
    [optionsOut autorelease] ;
#endif
    
    return optionsOut ;
}

- (NSDictionary*)patchOptions:(NSDictionary*)options
                     storeURL:(NSURL*)storeURL
                       caller:(const char*)caller {
    NSDictionary* actualSqlitePragmas = [options objectForKey:NSSQLitePragmasOption] ;
    NSDictionary* expectedSqlitePragmas = [[self class] sqlitePragmasForRollback] ;
    if (![actualSqlitePragmas isEqualToDictionary:expectedSqlitePragmas]) {
#if DEBUG
        NSLog(@"Patched options in %s while opening:\n%@\nNSSQLitePragmasOption was:\n%@\n"
              @"This can be caused either by your not adding the "
              @"NSSQLitePragmasOption for rollback journaling at some point "
              @"(Put a breakpoint in that method to debug), "
              @"or, during non-lightweight migrations, by Apple Bug .",
              __PRETTY_FUNCTION__,
              storeURL,
              actualSqlitePragmas) ;
#endif
        options = [[self class] dictionaryByAddingSqliteRollbackToDictionary:options] ;
    }
    
    return options ;
}


- (NSPersistentStore *)swizzledMigratePersistentStore:(NSPersistentStore *)store
                                                toURL:(NSURL *)storeURL
                                              options:(NSDictionary *)options
                                             withType:(NSString *)storeType
                                                error:(NSError **)error {
    if ([storeType isEqualToString:NSSQLiteStoreType]) {
        options = [self patchOptions:options
                            storeURL:storeURL
                              caller:__PRETTY_FUNCTION__] ;
    }
    
    return [self swizzledMigratePersistentStore:store
                                          toURL:storeURL
                                        options:options
                                       withType:storeType error:error] ;
}

- (NSPersistentStore *)swizzledAddPersistentStoreWithType:(NSString *)storeType
                                            configuration:(NSString *)configuration
                                                      URL:(NSURL *)storeURL
                                                  options:(NSDictionary *)options
                                                    error:(NSError **)error {
    if ([storeType isEqualToString:NSSQLiteStoreType]) {
        options = [self patchOptions:options
                            storeURL:storeURL
                              caller:__PRETTY_FUNCTION__] ;
    }
    
    return [self swizzledAddPersistentStoreWithType:storeType
                                      configuration:configuration
                                                URL:storeURL
                                            options:options
                                              error:error] ;
}

+ (void)swizzleMethod:(SEL)origSelector
        withNewMethod:(SEL)newSelector {
    Method origMethod = class_getInstanceMethod(self, origSelector) ;
    Method newMethod = class_getInstanceMethod(self, newSelector) ;
    
    if (origMethod && newMethod) {
        if(class_addMethod(self, origSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
            class_replaceMethod(self, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod)) ;
        }
        else {
            method_exchangeImplementations(origMethod, newMethod) ;
        }
    }
}

+ (void)load {
    [self swizzleMethod:@selector(addPersistentStoreWithType:configuration:URL:options:error:)
          withNewMethod:@selector(swizzledAddPersistentStoreWithType:configuration:URL:options:error:)] ;
    [self swizzleMethod:@selector(migratePersistentStore:toURL:options:withType:error:)
          withNewMethod:@selector(swizzledMigratePersistentStore:toURL:options:withType:error:)] ;
}

@end

