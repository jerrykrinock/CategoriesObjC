#import "NSUserDefaults+SSYOtherApps.h"
#import "NSDictionary+SimpleMutations.h"

@implementation NSUserDefaults (SSYOtherApps)

- (void)syncApplicationId:(NSString*)applicationId {
    Boolean ok = CFPreferencesAppSynchronize((CFStringRef)applicationId) ;
    if (!ok) {
        NSLog(@"Internal Error 624-3849 %@", applicationId) ;
    }
}

- (void)setValue:(id)value
          forKey:(NSString*)key
   applicationId:(NSString*)applicationId {
    if (key && applicationId) {
        // Passing NULL/nil to *value* is OK.  It removes the key/value.
        CFPreferencesSetAppValue(
                                 (CFStringRef)key,
                                 (CFPropertyListRef)value,
                                 (CFStringRef)applicationId
                                 ) ;
    }
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

- (id)valueForKey:(NSString*)key
    applicationId:(NSString*)applicationId {
    if (!key || !applicationId) {
        return nil ;
    }
    NSObject* value = CFBridgingRelease(CFPreferencesCopyAppValue(
                                                                  (CFStringRef)key,
                                                                  (CFStringRef)applicationId
                                                                  )) ;
    return value;
}

- (id)syncAndGetValueForKey:(NSString*)key
              applicationId:(NSString*)applicationId {
    if (!applicationId) {
        return nil ;
    }
    
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
#if !__has_feature(objc_arc)
    [dics release] ;
#endif
    NSMutableDictionary* copy ;
    for (NSDictionary* dic in e) {
        key = [keyArray objectAtIndex:i] ;
        copy = [dic mutableCopy] ;
        [copy setObject:nextObject
                 forKey:key] ;
#if !__has_feature(objc_arc)
        [copy autorelease];
#endif
        nextObject = copy;
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

- (void)       removeAndSyncKey:(id)key
                  applicationId:(NSString*)applicationId {
    CFPreferencesSetAppValue(
                             (CFStringRef)key,
                             NULL,  // indicator to remove the given key
                             (CFStringRef)applicationId
                             ) ;
    CFPreferencesAppSynchronize((CFStringRef)applicationId) ;
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

@end
