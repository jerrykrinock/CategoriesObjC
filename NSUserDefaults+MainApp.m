#import "NSUserDefaults+MainApp.h"
#import "NSBundle+MainApp.h"
#import "NSDictionary+SimpleMutations.h"
#import "NSArray+SSYMutations.h"

@implementation NSUserDefaults (MainApp)

- (void)syncApplicationId:(NSString*)applicationId {
   Boolean ok = CFPreferencesAppSynchronize((CFStringRef)applicationId) ;
    if (!ok) {
        NSLog(@"Internal Error 624-3849 %@", applicationId) ;
    }
}

- (void)setValue:(id)value
          forKey:(NSString*)key
   applicationId:(NSString*)applicationId {
    // Passing NULL/nil value to this method is OK.  It removes the key/value.
    CFPreferencesSetAppValue(
                             (CFStringRef)key,
                             (CFPropertyListRef)value,
                             (CFStringRef)applicationId
                             ) ;
}

- (void)setAndSyncValue:(id)value
                 forKey:(NSString*)key
          applicationId:(NSString*)applicationId {
    // Passing NULL/nil value to this method is OK.  It removes the key/value.
    [self setValue:value
            forKey:key
     applicationId:applicationId] ;
    [self syncApplicationId:applicationId] ;
}

- (NSObject*)valueForKey:(NSString*)key
           applicationId:(NSString*)applicationId {
    NSObject* value = CFPreferencesCopyAppValue(
                                                (CFStringRef)key,
                                                (CFStringRef)applicationId
                                                ) ;
    return [value autorelease] ;
}

- (NSObject*)syncAndGetValueForKey:(NSString*)key
                     applicationId:(NSString*)applicationId {
    [self syncApplicationId:applicationId] ;
    return [self valueForKey:key
               applicationId:applicationId] ;
}

- (id)valueForKeyPathArray:(NSArray*)keyPathArray
             applicationId:(NSString*)applicationId {
	// Don't use componentsJoinedByString:@"." because it is legal
	// for a key path to contain a dot/period.
	id obj = self ;
	for(id key in keyPathArray) {
		if (![obj respondsToSelector:@selector(objectForKey:)]) {
			// Corrupt pref?
			return nil ;
		}
		if (obj == self) {
            obj = [self valueForKey:key
                      applicationId:applicationId] ;
        }
        else {
            obj = [obj objectForKey:key] ;
        }
	}
	
	return obj;
}

- (id)syncAndGetValueForKeyPathArray:(NSArray*)keyPathArray
                       applicationId:(NSString*)applicationId {
    [self syncApplicationId:applicationId] ;
    return [self valueForKeyPathArray:keyPathArray
                        applicationId:applicationId] ;
}

- (void)setAndSyncValue:(id)value
        forKeyPathArray:(NSArray*)keyArray
   applicationId:(NSString*)applicationId {
	NSInteger N = [keyArray count] ;
	if (!value || (N < 1)) {
		return ;
	}
	
    // We sync now, because we need to read the dictionaries enclosing the
    // current value, if any.  We also sync at the end, after we have set
    // the new value.
    [self syncApplicationId:applicationId] ;
	
    NSMutableArray* dics = [[NSMutableArray alloc] init] ;
	id object = self ;
	id nextObject = value ;
	NSInteger i ;
	for (i=0; i<N-1; i++) {
		NSString* key = [keyArray objectAtIndex:i] ;
    
        if (object == self) {
            object = [self valueForKey:key
                         applicationId:applicationId] ;
        }
        else {
            object = [object objectForKey:key] ;
        }
        
		if ([object isKindOfClass:[NSDictionary class]]) {
			// Required dictionary already exists.  Stash it for later.
			[dics addObject:object] ;
		}
		else {
			// Dictionary does not exist staring at this level,
			// (or preferences are corrupt and we didn't get a
			// dictionary where one was expected.  In this case,
			// we will, I believe, later, silently overwrite the
			// corrupt object)
			// Make one, from the bottom up, starting with
			// the value and the last key in keyArray.
			// Then break out of the loop.
			NSInteger j  ;
			nextObject = value ;
			if (nextObject) {   // if () added as bug fix in BookMacster 1.14.4
                for (j=N-1; j>i; j--) {
                    NSString* aKey = [keyArray objectAtIndex:j] ;
                    nextObject = [NSDictionary dictionaryWithObject:nextObject
                                                             forKey:aKey] ;
                }
            }
			
			break ;
		}
	}
	
    NSString* key ;
    
	// Reverse-enumerate through the dictionaries, starting at
	// the inside and setting little dictionaries as objects
	// inside the bigger dictionaries
	NSEnumerator* e = [dics reverseObjectEnumerator] ;
    [dics release] ;
	NSMutableDictionary* copy ;
	for (NSDictionary* dic in e) {
        key = [keyArray objectAtIndex:i] ;
		copy = [dic mutableCopy] ;
		[copy setObject:nextObject
				 forKey:key] ;
// This statement removed in BookMacster 1.19.6.  It was a mistake
// to put this in here.
//        [self setValue:nextObject
//                forKey:[keyArray objectAtIndex:i]
//         applicationId:applicationId] ;
		nextObject = [copy autorelease] ;
		i-- ;
	}
	
    if (nextObject) {  // if() added as bug fix added in BookMaster 1.14.4
        key = [keyArray objectAtIndex:0] ;
        [self setValue:nextObject
                forKey:key
         applicationId:applicationId] ;
    }

    [self syncApplicationId:applicationId] ;
}

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



- (void)       removeAndSyncKey:(id)key
                  applicationId:(NSString*)applicationId {
    CFPreferencesSetAppValue(
                             (CFStringRef)key,
                             NULL,  // indicator to remove the given key
                             (CFStringRef)applicationId
                             ) ;
}

- (void)       removeAndSyncKey:(id)key
   fromDictionaryAtKeyPathArray:(NSArray*)keyPathArray
                  applicationId:(NSString*)applicationId {
    [self syncApplicationId:applicationId] ;
	NSDictionary* dictionary = [self valueForKeyPathArray:keyPathArray
                                            applicationId:applicationId] ;
	if (dictionary) {
		dictionary = [dictionary dictionaryBySettingValue:nil
												   forKey:key] ;
		[self setAndSyncValue:dictionary
              forKeyPathArray:keyPathArray
                applicationId:applicationId] ;
	}
	else {
		// The dictionary doesn't exist.  Don't do anything.
	}
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
