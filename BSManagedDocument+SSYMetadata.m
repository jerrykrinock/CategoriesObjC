#import "BSManagedDocument+SSYMetadata.h"
#import "NSManagedObjectContext+Cheats.h"
#import "SSYSqliter.h"
#import "NSObject+MoreDescriptions.h"
#import "NSDocument+SSYAutosaveBetter.h"
#import "NSError+DecodeCodes.h"
#import "NSError+MoreDescriptions.h"

@implementation BSManagedDocument (SSYMetadata)

+ (NSDictionary*)metadataAtPath:(NSString*)path {
    NSError* error = nil ;
    NSDictionary* metadata = nil ;

    path = [BSManagedDocument storePathForDocumentPath:path];

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
    }
    
    return metadata ;
}

+ (id)metadataObjectForKey:(NSString*)key
                      path:(NSString*)path {
    return [[self metadataAtPath:(NSString*)path] objectForKey:key] ;
}

- (id)metadataObjectForKey:(NSString*)key {
	NSDictionary* metadata = [[self managedObjectContext] metadata1] ;
    /* metadata could be nil if store has not been 
     ed yet. */
    id answer = nil;
	if (metadata) {
        answer = [metadata objectForKey:key] ;
    }
    else {
		// Probably the store has not been configured yet, so [[self managedObjectContext] store1]
		// returns nil.  Therefore, we are forced to get the metadata by cheating…
		NSString* path = [[self fileURL] path] ;
        if (path) {
            answer = [[self class] metadataObjectForKey:key
                                                   path:path] ;
        }
	}
    
    return answer ;
}

- (BOOL)setMetadataObject:(id)object
				   forKey:(NSString*)key
                  error_p:(NSError**)error_p {
    NSError* error = nil ;
	[[self managedObjectContext] setMetadata1Object:object
										   forKey:key
                                            error_p:&error] ;
    if (error) {
        if ([error code] == SSYManagedObjectContextCheatsErrorStoreIsReadOnly) {
            // This is expected when operating on store in Versions Browser
        }
        else {
            error = nil ;
        }
    }
	
    if (error && error_p) {
        *error_p = error ;
    }

    return (error == nil);
}	

- (void)addMetadata:(NSDictionary*)moreMetadata {
    [[self managedObjectContext] addMetadata1:moreMetadata];
}

@end
