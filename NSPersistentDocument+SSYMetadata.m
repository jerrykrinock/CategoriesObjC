#import "NSPersistentDocument+SSYMetadata.h"
#import "NSManagedObjectContext+Cheats.h"
#import "SSYSqliter.h"
#import "NSObject+MoreDescriptions.h"

@implementation NSPersistentDocument (SSYMetadata)

- (id)metadataObjectForKey:(NSString*)key {
	NSDictionary* metadata = [[self managedObjectContext] metadata1] ;
	if (!metadata) {
		// Probably the store has not been configured yet, so [[self managedObjectContext] store1]
		// returns nil.  Therefore, we are forced to get the metadata by cheating…
		NSError* error = nil ;
		NSString* path = [[self fileURL] path] ;
		SSYSqliter* sqliter = [[SSYSqliter alloc] initWithPath:path
													   error_p:&error] ;
		if (sqliter) {
			NSString* query = @"SELECT Z_PLIST FROM Z_METADATA" ;
			NSData* data = [sqliter firstRowFromQuery:query
												error:&error] ;
			if ([data isKindOfClass:[NSData class]]) {
				NSString* plistError = nil ;
				metadata = [NSPropertyListSerialization propertyListFromData:data
															mutabilityOption:NSPropertyListImmutable
																	  format:NULL
															errorDescription:&plistError] ;
				if (!metadata) {
					error = [NSError errorWithDomain:SSYManagedObjectContextCheatsErrorDomain
												code:315640
											userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
													  @"Could not deserialize metadata", NSLocalizedDescriptionKey,
													  plistError, @"Deserializer Error",
													  nil]] ;
				}
				if (![metadata respondsToSelector:@selector(objectForKey:)]) {
					error = [NSError errorWithDomain:SSYManagedObjectContextCheatsErrorDomain
												code:315641
											userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
													  @"Could not get objects from metadata", NSLocalizedDescriptionKey,
													  [metadata className], @"Metadata Class",
													  nil]] ;
				}
			}
			else {
#if 0
#warning Will raise error if pre-read metadata has no plist attribute
				error = [NSError errorWithDomain:SSYManagedObjectContextCheatsErrorDomain
											code:315642
										userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
												  @"No Metadata Plist (Maybe this is OK?)", NSLocalizedDescriptionKey,
												  [data className], @"Data Class",
												  nil]] ;
#else
				// Until BookMacster 1.6.3, I raised an error here.
				// But now I don't.  I suppose that this is normal, if I have never set
				// any metadata in the document.  Must be really old?  I don't know.
#endif
			}
		}

		[sqliter release] ;

		if (error) {
			error = [NSError errorWithDomain:SSYManagedObjectContextCheatsErrorDomain
										code:315650
									userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
											  @"Could not pre-read metadata", NSLocalizedDescriptionKey,
											  error, NSUnderlyingErrorKey,
											  path, @"Path",
											  key, @"Key",
											  nil]] ;
			NSLog(@"Internal Error 674-8448 in %s: %@", __PRETTY_FUNCTION__, [error longDescription]) ;
		}
	}		

	return [metadata objectForKey:key] ;
}

- (void)saveMetadataOnly {
	/*
	 Added in BookMacster 1.6.4 to detect the case when we are invoked from,
	 for example, this call stack…
	 #0	0x995d5c5e in semaphore_wait_trap
	 #1	0x9bb26874 in _dispatch_semaphore_wait_slow
	 #2	0x9bb26970 in dispatch_semaphore_wait
	 #3	0x9713b135 in -[NSDocument performActivityWithSynchronousWaiting:usingBlock:]
	 #4	0x971205cd in -[NSDocument saveDocumentWithDelegate:didSaveSelector:contextInfo:]
	 #5	0x971201e0 in -[NSDocument saveDocument:]
	 #6	0x0022801c in -[NSPersistentDocument(SSYMetadata) saveMetadataOnly] at NSPersistentDocument+SSYMetadata.m:81
	 #7	0x0017c570 in -[Bkmslf upgradeBrowprietaries] at Bkmslf.m:1680
	 #8	0x0017d9d9 in -[Bkmslf readFromURL:ofType:error:] at Bkmslf.m:1952
	 #9	0x96fb979d in -[NSDocument _initForURL:withContentsOfURL:ofType:error:]
	 #10	0x96fb9687 in -[NSDocument initForURL:withContentsOfURL:ofType:error:]
	 #11	0x96fb93fc in -[NSDocumentController makeDocumentForURL:withContentsOfURL:ofType:error:]
	 #12	0x9714dba8 in -[NSDocumentController duplicateDocumentWithContentsOfURL:copying:displayName:error:]
	 as the result of using clicking menu File ▸ Duplicate, then the Duplicate button.
	 In that case, fileURL is nil and -[saveDocument never returns, blocks forever!
	 */
		
	 
	
	if (![[self managedObjectContext] hasChanges]) {
		if ([self respondsToSelector:@selector(invalidateRestorableState)]) {
			// OS X Lion 10.7
			NSError* error = nil ;
			BOOL ok = [[self managedObjectContext] save:&error] ;
			if (!ok) {
				NSLog(@"Internal Error 624-0393 saving metadata: %@", [error longDescription]) ;
			}
		}
		else {
			// Mac OS X 10.5 or 10.6	
			[super saveDocument:self] ;
			// I tried using [[self managedObjectContext] save:] instead of the
			// above, but that resulted in a sheet being presented the *next*
			// time I saved, with the dreaded warning that another app had
			// modified the document.  This doesn't happen in Lion.
		}
	}
}


- (void)setMetadataObject:(id)object
				   forKey:(NSString*)key {
	[[self managedObjectContext] setMetadata1Object:object
										   forKey:key] ;
	[self saveMetadataOnly] ;
}	

- (void)addMetadata:(NSDictionary*)moreMetadata {
	[[self managedObjectContext] addMetadata1:moreMetadata] ;
	[self saveMetadataOnly] ;
}	

@end