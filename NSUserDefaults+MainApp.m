#import "NSUserDefaults+MainApp.h"
#import "NSBundle+MainApp.h"
#import "NSDictionary+SimpleMutations.h"
#import "NSArray+SSYMutations.h"
#import "NSUserDefaults+SSYOtherApps.h"

@implementation NSUserDefaults (MainApp)

- (id)syncAndGetMainAppValueForKeyPathArray:(NSArray*)keyPathArray {
    return [self syncAndGetValueForKeyPathArray:keyPathArray
                                  applicationId:[[NSBundle mainAppBundle] bundleIdentifier]] ;
}

- (id)syncAndGetMainAppValueForKey:(NSString*)key {
    return [self syncAndGetValueForKeyPathArray:[NSArray arrayWithObject:key]
                                  applicationId:[[NSBundle mainAppBundle] bundleIdentifier]] ;
}

- (void)setAndSyncMainAppValue:(id)value
               forKeyPathArray:(NSArray*)keyArray {
    [self setAndSyncValue:value
          forKeyPathArray:keyArray
            applicationId:[[NSBundle mainAppBundle] bundleIdentifier]] ;
}

- (void)setAndSyncMainAppValue:(id)value
                        forKey:(NSString*)key {
    [self setAndSyncValue:value
          forKeyPathArray:[NSArray arrayWithObject:key]
            applicationId:[[NSBundle mainAppBundle] bundleIdentifier]] ;
}

#if 0
- (void)incrementIntValueForKey:(id)innerKey
		  inDictionaryAtKeyPath:(id)outerKeyPath {
	NSString* keyPath = [NSString stringWithFormat:
						 @"%@.%@",
						 outerKeyPath,
						 innerKey] ;
	NSNumber* number = [self valueForKeyPath:keyPath] ;
	NSInteger value = 0 ;
	// We are careful since user defaults may be corrupted.
	if ([number respondsToSelector:@selector(integerValue)]) {
		value = [number integerValue] ;
	}
    
	value++ ;
	
	number = [NSNumber numberWithInteger:value] ;
	
	[self setValue:number
		forKeyPath:keyPath] ;
}
#endif

- (void)syncAndIncrementIntValueForMainAppKey:(id)innerKey
                        inDictionaryAtKeyPath:(id)outerKeyPath {
	NSArray* keyPathArray = [outerKeyPath componentsSeparatedByString:@"."] ;
    keyPathArray = [keyPathArray arrayByAddingObject:[NSString stringWithFormat:@"%ld", (long)[innerKey integerValue]]] ;
    
	NSNumber* number = [self syncAndGetMainAppValueForKeyPathArray:keyPathArray] ;
	NSInteger value = 0 ;
	// We are careful since user defaults may be corrupted.
	if ([number respondsToSelector:@selector(integerValue)]) {
		value = [number integerValue] ;
	}
    
	value++ ;
	number = [NSNumber numberWithInteger:value] ;
	
	[self setAndSyncMainAppValue:number
                 forKeyPathArray:keyPathArray] ;
}



- (void)addAndSyncMainAppObject:(id)object
          toArrayAtKeyPathArray:(NSArray*)keyPathArray {
	NSArray* array = [self syncAndGetMainAppValueForKeyPathArray:keyPathArray] ;
	if (array) {
		array = [array arrayByAddingObject:object] ;
	}
	else {
		array = [NSArray arrayWithObject:object] ;
	}
	
	[self setAndSyncMainAppValue:array
                 forKeyPathArray:keyPathArray] ;
}



- (void)removeAndSyncMainAppObject:(id)object
           fromArrayAtKeyPathArray:(NSArray*)keyPathArray {
	NSArray* array = [self syncAndGetMainAppValueForKeyPathArray:keyPathArray] ;
	if (array) {
		array = [array arrayByRemovingObject:object] ;
		[self setAndSyncMainAppValue:array
                     forKeyPathArray:keyPathArray] ;
	}
	else {
		// The array doesn't exist.  Don't do anything.
	}
}

- (void)removeAndSyncMainAppObject:(id)object
                    fromArrayAtKey:(NSString*)key {
    [self removeAndSyncMainAppObject:object
             fromArrayAtKeyPathArray:[NSArray arrayWithObject:key]] ;
}

- (void)removeAndSyncMainAppKey:(NSString*)innerKey
   fromDictionaryAtKeyPathArray:(NSArray*)keyPathArray {
    [self      removeAndSyncKey:innerKey
   fromDictionaryAtKeyPathArray:keyPathArray
                  applicationId:[[NSBundle mainAppBundle] bundleIdentifier]] ;
}

- (void)removeAndSyncMainAppKey:(NSString*)innerKey
            fromDictionaryAtKey:(NSString*)key {
    [self removeAndSyncMainAppKey:innerKey
     fromDictionaryAtKeyPathArray:[NSArray arrayWithObject:key]] ;
}

- (BOOL)syncAndGetMainAppBoolForKey:(NSString*)key {
    NSNumber* boolObject = [self syncAndGetMainAppValueForKey:key] ;
    BOOL answer ;
    if ([boolObject respondsToSelector:@selector(boolValue)]) {
        answer = [boolObject boolValue] ;
    }
    else {
        answer = NO ;
    }
    
    return answer ;
}

- (void)setAndSyncMainAppBool:(BOOL)aBool
                       forKey:(NSString*)key {
    NSNumber* value = [NSNumber numberWithBool:aBool] ;
    [self setAndSyncMainAppValue:value
                          forKey:key] ;    
}

- (void)removeAndSyncMainAppKey:(NSString*)key {
    [self removeAndSyncKey:key
             applicationId:[[NSBundle mainAppBundle] bundleIdentifier]] ;
}



@end
