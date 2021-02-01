#import "NSManagedObjectContext+Cheats.h"
#import "NSManagedObjectModel+Versions.h"
#import "NSString+MorePaths.h"
#import "NSBundle+SSYMotherApp.h"
#import "NSBundle+MainApp.h"
#import "NSEntityDescription+SSYMavericksBugFix.h"
#import "NSPersistentStoreCoordinator+PatchRollback.h"

NSString* const SSYManagedObjectContextCheatsErrorDomain = @"SSYManagedObjectContextCheatsErrorDomain" ;
NSString* const SSYManagedObjectContextPathExtensionForSqliteStores = @"sql" ;

@implementation NSManagedObjectContext (Cheats)

- (NSPersistentStore*)store1 {
	NSArray* stores = [[self persistentStoreCoordinator] persistentStores] ;
	NSPersistentStore* store = [stores firstObject] ;

	return store ;
}

- (NSString*)path1 {
	return [[[self store1] URL] path] ;
}

- (NSManagedObject*)singularObjectOfEntityName:(NSString*)entityName
									 predicate:(NSPredicate*)predicate
									findings_p:(NSInteger*)findings_p {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init] ;
	NSError* error = nil ;
	NSArray* fetchResults = nil ;
	
	@try {
		NSEntityDescription* entity = [NSEntityDescription SSY_entityForName:entityName
                                                      inManagedObjectContext:self] ;
		[fetchRequest setEntity:entity] ;
		if (predicate) {
			[fetchRequest setPredicate:predicate] ;
		}
		fetchResults = [self executeFetchRequest:fetchRequest
										   error:&error] ;
	}
	@finally {
	}
	[fetchRequest release];
	
	NSManagedObject* object = nil ;
	NSInteger n = [fetchResults count] ;
	if (n == 1) {
		object = [fetchResults objectAtIndex:0] ;
	}
	else if (n < 1) {
		object = [NSEntityDescription insertNewObjectForEntityForName:entityName
											   inManagedObjectContext:self] ;
	}
	else {
		for (NSInteger i=0; i<[fetchResults count]; i++) {
			NSManagedObject* anObject = [fetchResults objectAtIndex:i] ;
			[self deleteObject:anObject] ;
		}
	}

	if (findings_p) {
		*findings_p = n ;
	}
	
	return object ;
}

- (NSCountedSet*)contentSummary {
	NSCountedSet* countedSet = [[NSCountedSet alloc] init] ;
	for (NSManagedObject* object in [self registeredObjects]) {
		NSString* entityName = [[object entity] name] ;
		[countedSet addObject:entityName] ;
	}
	
	return [countedSet autorelease] ;
}

- (void)logContentSummaryWithPreface:(NSString*)preface {
	NSCountedSet* countedSet = [self contentSummary] ;
	NSString* msg = @"Contents of moc" ;
	NSString* path = [[[self store1] URL] path] ;
	if (path) {
		msg = [msg stringByAppendingFormat:
			   @" at %@",
			   path] ;
	}
	if (preface) {
		msg = [preface stringByAppendingFormat:
			   @": %@",
			   msg] ;
	}
	NSLog(@"%@", msg) ;

	NSLog(@"%@", countedSet) ;
}

- (NSDictionary*)metadata1 {
	return [[self store1] metadata] ;
}

- (id)metadata1ObjectForKey:(id)key {
	return [[self metadata1] objectForKey:key] ;
}

- (BOOL)setMetadata1Object:(id)object
                    forKey:(id)key
                   error_p:(NSError**)error_p {
    BOOL result = NO ;
    NSError* error = nil ;
	NSMutableDictionary* metadata = [[self metadata1] mutableCopy] ;
    if (object) {
        [metadata setObject:object
                     forKey:key] ;
    } else {
        [metadata removeObjectForKey:key];
    }
	NSPersistentStoreCoordinator* persistentStoreCoordinator = [self persistentStoreCoordinator] ;
    NSPersistentStore* persistentStore = [self store1] ;
	if (!persistentStore) {
		error = [NSError errorWithDomain:SSYManagedObjectContextCheatsErrorDomain
                                    code:SSYManagedObjectContextCheatsErrorCouldNotGetStore
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                          @"Could not get store", NSLocalizedDescriptionKey,
                                          nil]] ;
	}
    else if ([persistentStore isReadOnly]) {
		NSString* desc = [NSString stringWithFormat:
                          @"Store is readonly : %@",
                          [persistentStore URL]] ;
        error = [NSError errorWithDomain:SSYManagedObjectContextCheatsErrorDomain
                                    code:SSYManagedObjectContextCheatsErrorStoreIsReadOnly
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                          desc, NSLocalizedDescriptionKey,
                                          nil]] ;
    }
    else {
        [persistentStoreCoordinator setMetadata:metadata
                             forPersistentStore:persistentStore] ;
        result = YES ;
    }

    if (error) {
        if (error_p) {
            *error_p = error ;
        }
        else {
            NSLog(@"Error in %s: %@", __PRETTY_FUNCTION__, [error localizedDescription]) ;
        }
    }
    
	[metadata release] ;
    
    return result ;
}

- (BOOL)addMetadata1:(NSDictionary*)moreMetadata {
	BOOL didDoAnything = NO ;
	NSDictionary* oldMetadata = [self metadata1] ;
	NSMutableDictionary* metadata = [oldMetadata mutableCopy] ;
	[metadata addEntriesFromDictionary:moreMetadata] ;
	if (![metadata isEqualToDictionary:oldMetadata]) {
		[[self store1] setMetadata:metadata] ;
		didDoAnything = YES ;
	}
	[metadata release] ;
	
	return didDoAnything ;
}

- (NSManagedObject*)objectWithUri:(NSString*)uri {
	NSPersistentStoreCoordinator* psc = [self persistentStoreCoordinator] ;
	NSURL* url = [NSURL URLWithString:uri] ;
    NSManagedObjectID* objectId = nil ;
    // Cocoa will terminate app due to uncaught exception if, for one thing
    // at least, the url passed in the next line is not of the
    // scheme x-coredata, ("x-coredata://").  So, starting in
    // BookMacster 1.14.4, we @try…
    @try {
        objectId = [psc managedObjectIDForURIRepresentation:url] ;
    }
    @catch (NSException *exception) {
        NSLog(@"Internal Error 213-0594  Bad Core Data URI: %@.  %@", uri, exception) ;
    }

	NSManagedObject* object ;
	if (objectId) {
		NSError* error = nil ;
		object = [self existingObjectWithID:objectId
									  error:&error] ;
		// If asking this method for nonexistent objects is expected,
		// you should delete this…
		if (error) {
#if DEBUG
			// Be more verbose
            NSString* backtrace = SSYDebugBacktraceDepth(8) ;
#else
			// Be less verbose
            NSString* backtrace = SSYDebugCaller() ;
#endif
			NSLog(@"Warning 927-4139 (not really an error) : %@ for %@", error, backtrace) ;
            
            if (object != nil) {
                // I think this indicates a bug in macOS, because
                // -existingObjectWithID:error: is documented to return nil
                // if anything bad happens.
                NSLog(@"Warning 927-4140  object=%p", object) ;
            }
		}
	}
	else {
		object = nil ;
	}
	
	return object ;
}



/*
 // This method is not needed since -updatedObjects already behaves this way.
 - (NSSet*)updatedObjectsReally {
	NSMutableSet* updatedObjectsReally = [[NSMutableSet alloc] init] ;
	for (NSManagedObject* object in [self updatedObjects]) {
		NSDictionary* newValuesDic = [object changedValues] ;
		NSDictionary* oldValuesDic = [object committedValuesForKeys:[newValuesDic allKeys]] ;
		BOOL isChanged = NO ;
		for (NSString* key in newValuesDic) {
			isChanged = ![NSObject isEqualHandlesNilObject1:[newValuesDic objectForKey:key]
													object2:[oldValuesDic objectForKey:key]] ;
			if (isChanged) {
				[updatedObjectsReally addObject:object] ;
				//break ;
			}
		}
	}
	
	NSSet* answer = [NSSet setWithSet:updatedObjectsReally] ;
	[updatedObjectsReally release] ;
	
	return answer ;
}
*/

@end
