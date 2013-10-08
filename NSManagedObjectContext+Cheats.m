#import "NSManagedObjectContext+Cheats.h"
#import "NSArray+SafeGetters.h"
#import "NSManagedObjectModel+Versions.h"
#import "NSString+MorePaths.h"
#import "BkmxBasis.h"

NSString* const SSYManagedObjectContextCheatsErrorDomain = @"SSYManagedObjectContextCheatsErrorDomain" ;
NSString* const SSYManagedObjectContextPathExtensionForSqliteStores = @"sql" ;

@implementation NSManagedObjectContext (Cheats)

- (NSPersistentStore*)store1 {
	NSArray* stores = [[self persistentStoreCoordinator] persistentStores] ;
	NSPersistentStore* store = [stores firstObjectSafely] ;

	return store ;
}

- (NSString*)path1 {
	return [[[self store1] URL] path] ;
}

+ (NSManagedObjectContext*)contextForSqlFilename:(NSString*)sqlFilename
										momdName:(NSString*)momdName
								modelVersionName:(NSString*)versionName
										brutally:(BOOL)brutally
										 error_p:(NSError**)error_p {
	NSString* errorDescription = nil ;
	NSInteger errorCode = 0 ;
	NSError* error = nil ;
	NSManagedObjectContext* managedObjectContext = nil ;
	
	NSManagedObjectModel* mom = [NSManagedObjectModel managedObjectModelWithMomdName:momdName
																		 versionName:versionName] ;
	if (!mom) {
		errorDescription = [NSString stringWithFormat:
							@"Could not find managed object model %@ in %@",
							versionName,
							momdName] ;
		errorCode = SSYManagedObjectContextCheatsErrorNoManagedObjectModel ;
		goto end ;
	}
	
	NSPersistentStoreCoordinator* coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom] ;
	[coordinator autorelease] ;
	if (!coordinator) {
		errorDescription = [NSString stringWithFormat:
							@"Could not create persistent store coordinator for %@",
							versionName] ;
		errorCode = SSYManagedObjectContextCheatsErrorCouldNotCreatePSC ;
		goto end ;
	}
	
	sqlFilename = [sqlFilename stringByAppendingPathExtension:SSYManagedObjectContextPathExtensionForSqliteStores] ;
	NSString* path = [[NSString applicationSupportPathForMotherApp] stringByAppendingPathComponent:sqlFilename] ;
	NSURL* url = [NSURL fileURLWithPath:path] ;
	if (!url) {
		errorDescription = [NSString stringWithFormat:
							@"Could not create url for store %@",
							sqlFilename] ;
		errorCode = SSYManagedObjectContextCheatsErrorCouldNotCreateUrlForStore ;
		goto end ;
	}
	
	NSDictionary* options = nil ;
	if (!versionName) {
		options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 nil] ;
	}
	NSPersistentStore* persistentStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
																   configuration:nil
																			 URL:url
																		 options:options
																		   error:&error] ;
	
	if (!persistentStore) {
		if (brutally) {
			// Move the corrupt file, with one or more "#" appended to name.
			NSString* corruptPath = [path hashifiedPath] ;
			BOOL stealthOk = [[NSFileManager defaultManager] moveItemAtPath:path
																	 toPath:corruptPath
																	  error:&error] ;
			if (!stealthOk) {
				// Try to delete the damned thing
				BOOL ok = [[NSFileManager defaultManager] removeItemAtPath:path
																	 error:&error] ;
				if (!ok) {
					errorDescription = [NSString stringWithFormat:
										@"Could not delete corrupt store %@",
										path] ;
					errorCode = SSYManagedObjectContextCheatsErrorCouldNotDeleteCorruptStore ;
					goto end ;
				}
			}
			
			// Make a new one
			persistentStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
														configuration:nil
																  URL:url
															  options:options
																error:&error] ;
			
			if (!persistentStore) {
				errorDescription = [NSString stringWithFormat:
									@"Could not replace corrupt store %@",
									url] ;
				errorCode = SSYManagedObjectContextCheatsErrorCouldNotFReplaceCorruptStore ;
				goto end ;
			}
		}
		else {
			errorDescription = [NSString stringWithFormat:
								@"Could not create store %@",
								url] ;
			errorCode = SSYManagedObjectContextCheatsErrorCouldNotCreateStore ;
			goto end ;
		}
	}
	
	managedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease] ;
	[managedObjectContext setPersistentStoreCoordinator:coordinator] ;
	[managedObjectContext setMergePolicy:NSOverwriteMergePolicy] ;
	[managedObjectContext setUndoManager:nil] ;
	
end:
	if ((errorCode != 0) && error_p) {
		*error_p = [NSError errorWithDomain:SSYManagedObjectContextCheatsErrorDomain
									   code:errorCode
								   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
											 errorDescription, NSLocalizedDescriptionKey,
											 error, NSUnderlyingErrorKey, // may be nil
											 nil]] ;
	}
	
	return managedObjectContext ;
}

- (NSManagedObject*)singularObjectOfEntityName:(NSString*)entityName
									 predicate:(NSPredicate*)predicate
									findings_p:(NSInteger*)findings_p {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init] ;
	NSError* error = nil ;
	NSArray* fetchResults = nil ;
	
	@try {
		NSEntityDescription* entity = [NSEntityDescription entityForName:entityName
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
	[metadata setObject:object
				 forKey:key] ;
	NSPersistentStoreCoordinator* persistentStoreCoordinator = [self persistentStoreCoordinator] ;
	NSPersistentStore* persistentStore = [self store1] ;
	if (![persistentStore isReadOnly]) {
		[persistentStoreCoordinator setMetadata:metadata
							 forPersistentStore:persistentStore] ;
        result = YES ;
	}
	else if (!persistentStore) {
		error = [NSError errorWithDomain:SSYManagedObjectContextCheatsErrorDomain
                                    code:SSYManagedObjectContextCheatsErrorCouldNotGetStore
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                          @"Could not get store", NSLocalizedDescriptionKey,
                                          nil]] ;
	}
    else {
		NSString* desc = [NSString stringWithFormat:
                          @"Store is readonly : %@",
                          [persistentStore URL]] ;
        error = [NSError errorWithDomain:SSYManagedObjectContextCheatsErrorDomain
                                    code:SSYManagedObjectContextCheatsErrorStoreIsReadOnly
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                          desc, NSLocalizedDescriptionKey,
                                          nil]] ;
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
		// Prior to BookMacster 1.9.3, we just did this here:
		// object = [self objectWithID:objectId] ;
		// That sometimes caused Core Data exceptions as explained below.
#if (MAC_OS_X_VERSION_MIN_REQUIRED < 1060) 
		// Mac OS X 10.5 or earlier
		object = [self objectWithID:objectId] ;
		// If an object with objectId does not exist in the store, -objectWithID: will
		// "helpfully" create a bogus object which will raise a "Core Data could not
		// fulfill a fault" exception when we try to access any of its properties.
		// (This behavior is per documentation.)
		// The solution to this problem is to immediately test the object by
		// trying to access one of its properties in a @try/catch block and
		// catching the "Core Data could not fulfill a fault" exception.
		// Amazingly, I tested this kludge and it actually worked, 3 times!
		id value = nil ;
		@try {
			NSDictionary* attributes = [[object entity] propertiesByName] ;
			NSArray* keys = [attributes allKeys] ;
			NSString* aKey = [keys firstObjectSafely] ;
			value = [object valueForKey:aKey] ;
		}
		@catch (NSException* exception) {
			// If asking this method for nonexistent objects is expected,
			// you should delete the next line…
			NSLog(@"Warning 927-6429 %@ : %@", exception, value) ;
			object = nil ;
		}
		@finally {
		}
#else
		// Mac OS X 10.6 or later
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
                // I think this indicates a bug in Mac OS X, because
                // -existingObjectWithID:error: is documented to return nil
                // if anything bad happens.
                NSLog(@"Warning 927-4140  object=%p", object) ;
            }
		}
#endif
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