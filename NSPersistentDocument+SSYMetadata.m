#import "NSPersistentDocument+SSYMetadata.h"
#import "NSManagedObjectContext+Cheats.h"
#import "SSYSqliter.h"
#import "NSObject+MoreDescriptions.h"
#import "NSDocument+SSYAutosaveBetter.h"

@implementation NSPersistentDocument (SSYMetadata)

+ (id)metadataObjectForKey:(NSString*)key
                      path:(NSString*)path {
    NSError* error = nil ;
    NSDictionary* metadata = nil ;
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
                metadata = nil ;
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
    
    return [metadata objectForKey:key] ;
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
		// This is very tricky.  In this switch, we want to know whether
		// we are in pre-10.7 or post-10.7, because we're going to do a
		// different kind of save.  We are *not* asking whether or not
		// self responds to -isInViewingMode.  Actually, in BookMacster 1.7.2,
		// we have, for convenience, defined -isInViewingMode in our
		// NSPersistentDocument subclass, regardless of Mac OS X version !
		// Probably I could use 1100.0 as threshold for Lion.
		// 10.7.1 is 1138.0.
		if (NSAppKitVersionNumber >= 1115.2) {
			// We're in OS X Lion 10.7
			// *By the way*, that means that we respond to -isInViewingMode
			if (![self ssy_isInViewingMode]) {
                NSError* error = nil ;
				BOOL ok = [[self managedObjectContext] save:&error] ;
				if (!ok) {
				    NSLog(@"Internal Error 624-0393 saving metadata: %@", [error longDescription]) ;
				}
			}
		}
		else {
            /*
             Mac OS X 10.5 or 10.6
             I tried using [[self managedObjectContext] save:] instead of 
             [super saveDocument:self], but that resulted in a sheet being
             presented the *next* time I saved, with the dreaded warning that
             another app had modified the document.  This doesn't happen in Lion.
             */
            [super saveDocument:self] ;
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