#import "NSPersistentDocument+SSYMetadata.h"
#import "NSManagedObjectContext+Cheats.h"
#import "SSYSqliter.h"
#import "NSObject+MoreDescriptions.h"
#import "NSDocument+SSYAutosaveBetter.h"
#import "NSError+DecodeCodes.h"
#import "NSError+MoreDescriptions.h"

@implementation NSPersistentDocument (SSYMetadata)

+ (NSDictionary*)metadataAtPath:(NSString*)path {
    NSError* error = nil ;
    NSDictionary* metadata = nil ;
    SSYSqliter* sqliter = [[SSYSqliter alloc] initWithPath:path
                                                   error_p:&error] ;
    if ([error involvesCode:SQLITE_ERROR domain:SSYSqliterErrorDomain]) {
        // This will happen if the query "SELECT Z_PLIST FROM Z_METADATA"
        // returned an error "no such table: Z_METADATA".
        // Starting with BookMacster 1.20.5, we log it here and then
        // do not return it up the call chain.
        NSLog(@"Warning 928-2991 Opening %@ produced error: %@",
              path,
              [error deepSummary]) ;
        error = nil ;
    }
    else if (sqliter) {
        NSString* query = @"SELECT Z_PLIST FROM Z_METADATA" ;
        NSData* data = [sqliter firstRowFromQuery:query
                                            error:&error] ;
        if ([error involvesCode:SQLITE_ERROR domain:SSYSqliterErrorDomain]) {
            /* This will happen if the query "SELECT Z_PLIST FROM Z_METADATA"
             returned an error "no such table: Z_METADATA".  It occurs
             expectedly when attempting to get metadata from Exids and
             Settings files when creating a new document.
            Starting with BookMacster 1.20.5, we log it or ignore it… */
#if 0
#if DEBUG
            NSLog(@"Warning 928-2526 (shown in DEBUG builds only).  Query:\n%@\nfrom %@\nproduced error:\n%@",
                  query,
                  path,
                  [error deepSummary]) ;
#else
#warning Ignoring Warning 928-2526 in Release builds.
#endif
#endif
            // Ignore it.
            error = nil ;
        }
        else {
            if ([data isKindOfClass:[NSData class]]) {
                NSError* plistError = nil ;
                metadata = [NSPropertyListSerialization propertyListWithData:data
                                                                     options:NSPropertyListImmutable
                                                                      format:NULL
                                                                       error:&plistError] ;
                if (!metadata) {
                    error = [NSError errorWithDomain:SSYManagedObjectContextCheatsErrorDomain
                                                code:315640
                                            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"Could not deserialize metadata", NSLocalizedDescriptionKey,
                                                      plistError, NSUnderlyingErrorKey,
                                                      nil]] ;
                }
                else if (![metadata respondsToSelector:@selector(objectForKey:)]) {
                    error = [NSError errorWithDomain:SSYManagedObjectContextCheatsErrorDomain
                                                code:315641
                                            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"Could not get objects from metadata", NSLocalizedDescriptionKey,
                                                      [metadata className], @"Metadata Class",
                                                      nil]] ;
                    metadata = nil ;
                }
            }
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
                                          // key, @"Key", Removed in BookMacster 1.20.5
                                          nil]] ;
        NSLog(@"Internal Error 674-8448 in %s: %@", __PRETTY_FUNCTION__, [error longDescription]) ;
    }
    
    return metadata ;
}

+ (id)metadataObjectForKey:(NSString*)key
                      path:(NSString*)path {
    return [[self metadataAtPath:(NSString*)path] objectForKey:key] ;
}

- (id)metadataObjectForKey:(NSString*)key {
	NSDictionary* metadata = [[self managedObjectContext] metadata1] ;
    id answer ;
	if (metadata) {
        answer = [metadata objectForKey:key] ;
    }
    else {
		// Probably the store has not been configured yet, so [[self managedObjectContext] store1]
		// returns nil.  Therefore, we are forced to get the metadata by cheating…
		NSString* path = [[self fileURL] path] ;
        answer = [[self class] metadataObjectForKey:key
                                                 path:path] ;
	}
    
    return answer ;
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
	 #7	0x0017c570 in -[BkmxDoc upgradeBrowprietaries] at BkmxDoc.m:1680
	 #8	0x0017d9d9 in -[BkmxDoc readFromURL:ofType:error:] at BkmxDoc.m:1952
	 #9	0x96fb979d in -[NSDocument _initForURL:withContentsOfURL:ofType:error:]
	 #10	0x96fb9687 in -[NSDocument initForURL:withContentsOfURL:ofType:error:]
	 #11	0x96fb93fc in -[NSDocumentController makeDocumentForURL:withContentsOfURL:ofType:error:]
	 #12	0x9714dba8 in -[NSDocumentController duplicateDocumentWithContentsOfURL:copying:displayName:error:]
	 as the result of using clicking menu File ▸ Duplicate, then the Duplicate button.
	 In that case, fileURL is nil and -[saveDocument never returns, blocks forever!
	 */
	
	if (![[self managedObjectContext] hasChanges]) {
        if (![self ssy_isInViewingMode]) {
            NSError* error = nil ;
            BOOL ok = [[self managedObjectContext] save:&error] ;
            if (!ok) {
                NSLog(@"Internal Error 624-0393 saving metadata: %@", [error longDescription]) ;
            }
        }
    }
}


- (void)setMetadataObject:(id)object
				   forKey:(NSString*)key
                  andSave:(BOOL)doSave {
    NSError* error = nil ;
	[[self managedObjectContext] setMetadata1Object:object
										   forKey:key
                                            error_p:&error] ;
    if (error) {
        if ([error code] == SSYManagedObjectContextCheatsErrorStoreIsReadOnly) {
            // This is expected when operating on store in Versions Browser
        }
        else {
            NSLog(@"Internal Error 292-0484  %@", [error localizedDescription]) ;
        }
    }
	
    if (doSave) {
        [self saveMetadataOnly] ;
    }
}	

- (void)addMetadata:(NSDictionary*)moreMetadata
            andSave:(BOOL)doSave {
	if ([[self managedObjectContext] addMetadata1:moreMetadata]) {
		if (doSave) {
            [self saveMetadataOnly] ;
        }
	}
}

@end
