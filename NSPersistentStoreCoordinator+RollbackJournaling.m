#import "NSPersistentStoreCoordinator+RollbackJournaling.h"
#import <objc/runtime.h>
#import <objc/message.h>

#if MAC_OS_X_VERSION_MAX_ALLOWED < 1070
#define NO_ARC 1
#else
#if __has_feature(objc_arc)
#define NO_ARC 0
#else
#define NO_ARC 1
#endif
#endif


@implementation NSPersistentStoreCoordinator (RollbackJournaling)

+ (NSDictionary*)dictionaryByAddingSqliteRollbackToDictionary:(NSDictionary*)optionsIn {
    NSMutableDictionary* mutant = [[NSMutableDictionary alloc] init] ;
    if (optionsIn) {
        [mutant addEntriesFromDictionary:optionsIn] ;
    }
    NSDictionary* sqlitePragmas = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   @"DELETE", @"journal_mode",
                                   nil] ;
    [mutant setObject:sqlitePragmas
               forKey:NSSQLitePragmasOption] ;
    NSDictionary* optionsOut = [mutant copy] ;
    
#if NO_ARC
    [mutant release] ;
    [sqlitePragmas release] ;
    [optionsOut autorelease] ;
#endif
    
    return optionsOut ;
}


#if DEBUG

- (NSPersistentStore *)swizzledMigratePersistentStore:(NSPersistentStore *)store
                                                toURL:(NSURL *)URL
                                              options:(NSDictionary *)options
                                             withType:(NSString *)storeType
                                                error:(NSError **)error {
    NSString* journalMode = [[options objectForKey:NSSQLitePragmasOption] objectForKey:@"journal_mode"] ;
    if ([storeType isEqualToString:NSSQLiteStoreType]) {
        if (!journalMode || ![journalMode isEqualToString:@"DELETE"]) {
            NSLog(@"ERROR: You have not set legacy rollback journaling.  "
                  @"To debug, set a breakpoint at %s:%d.", __FILE__, __LINE__+1) ;
            NSLog(@"Thank you.") ;
        }
    }
    
    return [self swizzledMigratePersistentStore:store toURL:(NSURL *)URL options:options withType:storeType error:error];
}

- (NSPersistentStore *)swizzledAddPersistentStoreWithType:(NSString *)storeType
                                            configuration:(NSString *)configuration
                                                      URL:(NSURL *)storeURL
                                                  options:(NSDictionary *)options
                                                    error:(NSError **)error {
    NSString* journalMode = [[options objectForKey:NSSQLitePragmasOption] objectForKey:@"journal_mode"] ;
    if ([storeType isEqualToString:NSSQLiteStoreType]) {
        if (!journalMode || ![journalMode isEqualToString:@"DELETE"]) {
            NSLog(@"ERROR: You have not set legacy rollback journaling.  "
                  @"To debug, set a breakpoint at %s:%d.", __FILE__, __LINE__+1) ;
            NSLog(@"Thank you.") ;
        }
    }
    return [self swizzledAddPersistentStoreWithType:storeType configuration:configuration URL:storeURL options:options error:error];
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

#endif

@end

