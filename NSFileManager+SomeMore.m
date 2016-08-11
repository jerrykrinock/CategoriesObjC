#import "NSFileManager+SomeMore.h"
#import "NSError+InfoAccess.h"
#import "NSError+MyDomain.h"
#import "NSError+LowLevel.h"
#import "SSYUuid.h"

#import <fcntl.h>    

NSString* const SSYMoreFileManagerErrorDomain = @"SSYMoreFileManagerErrorDomain" ;

@implementation NSFileManager (SomeMore)

- (BOOL)removeIfExistsItemAtPath:(NSString*)path
						 error_p:(NSError**)error_p {
	if (!path) {
		return YES ;
	}
	
	if ([self fileExistsAtPath:path]) {
		return [self removeItemAtPath:path
								error:error_p] ;
	}
	
	return YES ;
}

- (BOOL)swapUrl:(NSURL*)url1
        withUrl:(NSURL*)url2
        error_p:(NSError**)error_p {
    NSString* backupItemName = [SSYUuid uuid] ;
    NSFileManagerItemReplacementOptions options = NSFileManagerItemReplacementWithoutDeletingBackupItem ;
    NSURL* resultingItemUrl = nil ;
    NSError* error = nil ;
    NSInteger errorCode = 0 ;
    BOOL ok = [[NSFileManager defaultManager] replaceItemAtURL:url1
                                                 withItemAtURL:url2
                                                backupItemName:backupItemName
                                                       options:options
                                              resultingItemURL:&resultingItemUrl
                                                         error:&error] ;
    if (ok) {
        NSURL* backupItemURL = [[url1 URLByDeletingLastPathComponent] URLByAppendingPathComponent:backupItemName] ;
        ok = [[NSFileManager defaultManager] moveItemAtURL:backupItemURL
                                                     toURL:url2
                                                     error:&error] ;
        if (!ok) {
            errorCode = 617002 ;
        }
    }
    else {
        errorCode = 617001 ;
    }

    if (error_p) {
		if (ok) {
			*error_p = nil ;
		}
		else {
			NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"Could not exchange files", NSLocalizedDescriptionKey,
								  [url1 description], @"url1",
								  [url2 description], @"url2",
								  error, NSUnderlyingErrorKey,
								  nil] ;
			*error_p = [NSError errorWithDomain:SSYMoreFileManagerErrorDomain
										   code:errorCode
									   userInfo:info] ;
		}
	}
	
	return ok ;
}

- (BOOL)touchPath:(NSString*)path
		  error_p:(NSError**)error_p {
	NSDictionary* attributes = [NSDictionary dictionaryWithObject:[NSDate date]
														   forKey:NSFileModificationDate] ;
	return [self setAttributes:attributes
				  ofItemAtPath:path
						 error:error_p] ;
}

- (NSDate*)modificationDateForPath:(NSString*)path {
	NSDictionary* fileAttributes = [self attributesOfItemAtPath:path
														  error:NULL] ;

	return [fileAttributes objectForKey:NSFileModificationDate] ;
}	

- (NSDate*)creationDateForPath:(NSString*)path {
    NSDictionary* fileAttributes = [self attributesOfItemAtPath:path
                                                          error:NULL] ;
    
    return [fileAttributes objectForKey:NSFileCreationDate] ;
}	

- (BOOL)createDirectoryIfNoneExistsAtPath:(NSString*)path
								  error_p:(NSError**)error_p {
	NSError* error = nil ;
	
	NSFileManager* fileManager = [NSFileManager defaultManager] ;
	BOOL isDirectory ;
	BOOL exists = [fileManager fileExistsAtPath:path
									isDirectory:&isDirectory] ;
	
	BOOL ok = YES ;
	if (exists && !isDirectory) {
		ok = [fileManager removeItemAtPath:path
									 error:&error] ;
		if (ok) {
            exists = NO ;
        }
        else {
			error = [SSYMakeError(35261, @"Could not remove file") errorByAddingUnderlyingError:error] ;
			[error errorByAddingUserInfoObject:path
										forKey:@"path"] ;
		}
 	}

	if (!exists) {
		NSNumber* octal755 = [NSNumber numberWithUnsignedLong:0755] ;
		// Note that, in 0755, the 0 is a prefix which says to interpret the
		// remainder of the digits as octal, just as 0x is a prefix which says to
		// interpret the remainder of the digits as hexidecimal.  It's in the C
		// language standard!
		NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
									octal755, NSFilePosixPermissions,
									nil] ;
		ok = [fileManager createDirectoryAtPath:path
					withIntermediateDirectories:YES
									 attributes:attributes
										  error:&error] ;
	}
	
	if (error && error_p) {
		*error_p = error ;
	}
	
	return ok ;
}

- (BOOL)fileIsPermanentAtPath:(NSString*)path {
    if (!path) {
        return NO ;
    }

    NSURL* url = [NSURL fileURLWithPath:path] ;
    NSFileManager* fm = [NSFileManager defaultManager] ;
    if (![fm fileExistsAtPath:path]) {
        return NO ;
    }
    
    NSURLRelationship relationship ;
    
    [fm getRelationship:&relationship
            ofDirectory:NSTrashDirectory
               inDomain:NSAllDomainsMask
            toItemAtURL:url
                  error:NULL] ;
    if (relationship == NSURLRelationshipContains) {
        return NO ;
    }
    
    [fm getRelationship:&relationship
            ofDirectory:NSCachesDirectory
               inDomain:NSAllDomainsMask
            toItemAtURL:url
                  error:NULL] ;
    if (relationship == NSURLRelationshipContains) {
        return NO ;
    }

    // It would be nice if the NSAutosavedInformationDirectory someday meant the
    // /.DocumentRevisions-V100/ directory, but probably the following refers
    // only to Documents/Autosaved which is the legacy generation of auto save.
    [fm getRelationship:&relationship
            ofDirectory:NSAutosavedInformationDirectory
               inDomain:NSAllDomainsMask
            toItemAtURL:url
                  error:NULL] ;
    if (relationship == NSURLRelationshipContains) {
        return NO ;
    }
    
    // Unfortunately, NSSearchPathDirectory does not offer an
    // NSTemporaryDirectory, so we use the path, and only in the Home
    // directory (the "user" domain), with or without the "/private" symlink
    NSURL* temporaryUrl ;
    
    temporaryUrl = [NSURL fileURLWithPath:NSTemporaryDirectory()] ;
    [fm getRelationship:&relationship
       ofDirectoryAtURL:temporaryUrl
            toItemAtURL:url
                  error:NULL] ;
    if (relationship == NSURLRelationshipContains) {
        return NO ;
    }

    temporaryUrl = [NSURL fileURLWithPath:[@"/private" stringByAppendingPathComponent:NSTemporaryDirectory()]] ;
    [fm getRelationship:&relationship
       ofDirectoryAtURL:temporaryUrl
            toItemAtURL:url
                  error:NULL] ;
    if (relationship == NSURLRelationshipContains) {
        return NO ;
    }
    
    if ([path length] < 1) {
        return NO ;
    }
    
	return YES ;
}

- (NSString*)pathToSpecialFolderType:(NSSearchPathDirectory)folderType {
    NSError* error = nil ;
    NSURL* url = [[NSFileManager defaultManager] URLForDirectory:folderType
                                                        inDomain:NSUserDomainMask
                                               appropriateForURL:nil
                                                          create:NO
                                                           error:&error] ;
    if (error) {
        NSLog(@"Internal Error 290-0349 %@", error) ;
    }
	return [url path] ;
}

- (short)unixAdvisoryLockStatusForPath:(NSString*)path {
    struct flock flock;
    flock.l_type    = F_WRLCK;   /* Probe for either Read or Write (aka Exclusive) lock */
    short answer ;
    int fd = open([path fileSystemRepresentation], O_RDONLY);
    if (fd >= 0) {
        struct flock daFlock;
        daFlock.l_type = F_WRLCK;   /* Probe for either Read or Write (aka Exclusive) lock */
        daFlock.l_start = 0 ;
        daFlock.l_len = 0 ;
        daFlock.l_whence = SEEK_SET ;
        
        if (fcntl(fd, F_GETLK, &daFlock) < 0) {
            // This is probably some kind of internal error.
            answer = -2 ;
        }
        else {
            answer = daFlock.l_type ;
        }
        close(fd) ;
    }
    else {
        // Path does not exist, not accessible, etc.
        answer = -1 ;
    }
    
    return answer ;
}

- (BOOL)removeThoughtfullyPath:(NSString*)path
					   error_p:(NSError**)error_p {
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		return YES ;
	}
	
	NSError* error = nil  ;
	BOOL ok = [[NSFileManager defaultManager] removeItemAtPath:path
														 error:&error] ;
	if (!ok && error_p) {
		*error_p = SSYMakeError(922018, @"Could not delete item") ;
		*error_p = [*error_p errorByAddingUserInfoObject:path
												  forKey:@"Path"] ;
		*error_p = [*error_p errorByAddingUnderlyingError:error] ;
		NSString* suggestion = [NSString stringWithFormat:
								@"Activate Finder and try to remove this item yourself:\n\n%@\n\n",
								path] ;
		*error_p = [*error_p errorByAddingLocalizedRecoverySuggestion:suggestion] ;
	}
	
	return ok ;
}


- (BOOL)trashPath:(NSString*)path
	 scriptFinder:(BOOL)scriptFinder
		  error_p:(NSError**)error_p {
    NSMutableArray* kludge = [[NSMutableArray alloc] init] ;
	
	BOOL ok = YES ;
	if (scriptFinder) {
		NSString* source = [NSString stringWithFormat:
							/**/@"with timeout 15 seconds\n"
							/**/  @"tell application \"Finder\"\n"
							/**/	@"delete POSIX file \"%@\"\n"
							/**/  @"end tell\n"
							/**/@"end timeout\n",
							path] ;
		NSAppleScript* script = [[NSAppleScript alloc] initWithSource:source];
		NSDictionary* errorDic = nil ;
		[script executeAndReturnError:&errorDic] ;
		[script release] ;
		if (errorDic) {
			ok = NO ;
			NSError* error = SSYMakeError(572286, @"Finder refused to trash path") ;
			error = [error errorByAddingUnderlyingError:[NSError errorWithAppleScriptErrorDictionary:errorDic]] ;
            [kludge addObject:error] ;
		}
	}
	else {
        NSArray* urls = @[[NSURL fileURLWithPath:path]] ;
        dispatch_semaphore_t sem = dispatch_semaphore_create(0) ;
        dispatch_queue_t aSerialQueue = dispatch_queue_create(
                                                              "com.sheepsystems.NSFileManager.SomeMore",
                                                              DISPATCH_QUEUE_SERIAL
                                                              ) ;
        dispatch_async(aSerialQueue, ^{
            [[NSWorkspace sharedWorkspace] recycleURLs:urls
                                     completionHandler:^void(NSDictionary *newURLs,
                                                             NSError* recycleError) {
                                         
                                         NSError* error = SSYMakeError(572287, @"Could not trash path") ;
                                         error = [error errorByAddingUnderlyingError:recycleError] ;
                                         [kludge addObject:error] ;
                                         dispatch_semaphore_signal(sem) ;
                                     }] ;
             }) ;
        dispatch_async(aSerialQueue, ^{
            dispatch_release(aSerialQueue) ;
        }) ;
        
        // Wait here in case error is set by completionHandler block
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER) ;
        dispatch_release(sem) ;
	}
	
    NSError* error = [kludge firstObject] ;
	if (error_p && error) {
		*error_p = [error errorByAddingUserInfoObject:path
											   forKey:@"Path Attempted to Trash"] ;		
	}
    
    [kludge release] ;
    
	return ok ;
}


@end
