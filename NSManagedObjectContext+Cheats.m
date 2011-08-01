#import "NSManagedObjectContext+Cheats.h"
#import "NSArray+SafeGetters.h"
#import "NSManagedObjectModel+Versions.h"
#import "NSString+MorePaths.h"
#import "NSObject+MoreDescriptions.h"
#import "NSObject+DoNil.h"
#import "NSFileManager+SomeMore.h"

NSString* const SSYManagedObjectContextCheatsErrorDomain = @"SSYManagedObjectContextCheatsErrorDomain" ;

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
	NSManagedObjectContext* managedObjectContext = nil ;
	
	NSManagedObjectModel* mom = [NSManagedObjectModel managedObjectModelWithMomdName:momdName
																		 versionName:versionName] ;
	if (!mom) {
		errorDescription = [NSString stringWithFormat:
							@"Could not find managed object model %@ in %@",
							versionName,
							momdName] ;
		errorCode = 613201 ;
		goto end ;
	}
	
	NSPersistentStoreCoordinator* coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom] ;
	[coordinator autorelease] ;
	if (!coordinator) {
		errorDescription = [NSString stringWithFormat:
							@"Could not create persistent store coordinator for %@",
							versionName] ;
		errorCode = 613202 ;
		goto end ;
	}
	
	sqlFilename = [sqlFilename stringByAppendingPathExtension:@"sql"] ;
	NSString* path = [[NSString applicationSupportFolderForThisApp] stringByAppendingPathComponent:sqlFilename] ;
	NSURL* url = [NSURL fileURLWithPath:path] ;
	if (!url) {
		errorDescription = [NSString stringWithFormat:
							@"Could not create url for store %@",
							sqlFilename] ;
		errorCode = 613203 ;
		goto end ;
	}
	
	NSDictionary* options = nil ;
	if (!versionName) {
		options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 nil] ;
	}
	NSError* error = nil ;
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
					errorCode = 613204 ;
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
				errorCode = 613205 ;
				goto end ;
			}
		}
		else {
			errorDescription = [NSString stringWithFormat:
								@"Could not create store %@",
								url] ;
			errorCode = 613206 ;
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

- (void)setMetadata1Object:(id)object
				   forKey:(id)key {
	NSMutableDictionary* metadata = [[self metadata1] mutableCopy] ;
	[metadata setObject:object
				 forKey:key] ;
	NSPersistentStoreCoordinator* persistentStoreCoordinator = [self persistentStoreCoordinator] ;
	NSPersistentStore* persistentStore = [self store1] ;
	if (persistentStore) {
		[persistentStoreCoordinator setMetadata:metadata
							 forPersistentStore:persistentStore] ;
	}
	else {
		NSError* error = [NSError errorWithDomain:SSYManagedObjectContextCheatsErrorDomain
											 code:315644
										 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
												   @"Could not get store", NSLocalizedDescriptionKey,
												   nil]] ;
		NSLog(@"Internal Error in %s: %@", __PRETTY_FUNCTION__, error) ;
	}
	
	[metadata release] ;
}

- (void)addMetadata1:(NSDictionary*)moreMetadata {
	NSDictionary* oldMetadata = [self metadata1] ;
	NSMutableDictionary* metadata = [oldMetadata mutableCopy] ;
	[metadata addEntriesFromDictionary:moreMetadata] ;
	[[self store1] setMetadata:metadata] ;
	[metadata release] ;
}

- (BOOL)trashStore1Error_p:(NSError**)error_p {
	NSURL* storeUrl = [[self store1] URL] ;
	NSString* path = [storeUrl path] ;
	NSError* error = nil ;
	BOOL ok = [[NSFileManager defaultManager] trashPath:path
												error_p:&error] ;
	return ok ;
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