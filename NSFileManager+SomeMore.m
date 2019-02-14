#import "NSFileManager+SomeMore.h"
#import "NSError+InfoAccess.h"
#import "NSError+MyDomain.h"
#import "NSError+LowLevel.h"
#import "SSYUuid.h"
#import "SSYAppleScripter.h"

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

- (BOOL)ensureDirectoryAtPath:(NSString*)path
                      error_p:(NSError**)error_p {
	NSError* error = nil ;
	
	BOOL isDirectory ;
    BOOL exists = [self fileExistsAtPath:path
                             isDirectory:&isDirectory] ;
	
	BOOL ok = YES ;
	if (exists && !isDirectory) {
        ok = [self removeItemAtPath:path
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
        ok = [self createDirectoryAtPath:path
             withIntermediateDirectories:YES
                              attributes:attributes
                                   error:&error] ;
	}
	
	if (error && error_p) {
		*error_p = error ;
	}
	
	return ok ;
}

- (BOOL)fileIsPermanentAtPath:(NSString*)path
                      error_p:(NSError**)error_p {
    BOOL ok = YES;
    NSError* error = nil;
    NSURL* url = nil;
    NSURLRelationship relationship;
    NSFileManager* fm;

    if (ok) {
        if (!path) {
            ok =  NO;
            error = [NSError errorWithDomain:SSYMoreFileManagerErrorDomain
                                        code:617010
                                    userInfo:@{NSLocalizedDescriptionKey: @"The given path is nil"}] ;
        }
    }

    if (ok) {
        url = [NSURL fileURLWithPath:path] ;
        fm = [NSFileManager defaultManager] ;
        if (![fm fileExistsAtPath:path]) {
            ok =  NO;
            error = [NSError errorWithDomain:SSYMoreFileManagerErrorDomain
                                        code:617011
                                    userInfo:@{NSLocalizedDescriptionKey: @"There is no file at the given path"}] ;
        }
    }

    if (ok) {
        [fm getRelationship:&relationship
                ofDirectory:NSTrashDirectory
                   inDomain:NSAllDomainsMask
                toItemAtURL:url
                      error:NULL] ;
        if (relationship == NSURLRelationshipContains) {
            ok =  NO;
            error = [NSError errorWithDomain:SSYMoreFileManagerErrorDomain
                                        code:617012
                                    userInfo:@{NSLocalizedDescriptionKey: @"The given path is in a Trash directory"}] ;
        }
    }

    if (ok) {
        [fm getRelationship:&relationship
                ofDirectory:NSCachesDirectory
                   inDomain:NSAllDomainsMask
                toItemAtURL:url
                      error:NULL] ;
        if (relationship == NSURLRelationshipContains) {
            ok =  NO;
            error = [NSError errorWithDomain:SSYMoreFileManagerErrorDomain
                                        code:617013
                                    userInfo:@{NSLocalizedDescriptionKey: @"The given path is in a Caches directory"}] ;
        }
    }

    if (ok) {
        /* It would be nice if the NSAutosavedInformationDirectory someday
         meant the /.DocumentRevisions-V100/ directory, but probably the
         following refers only to Documents/Autosaved which is the legacy
         generation of auto save. */
        [fm getRelationship:&relationship
                ofDirectory:NSAutosavedInformationDirectory
                   inDomain:NSAllDomainsMask
                toItemAtURL:url
                      error:NULL] ;
        if (relationship == NSURLRelationshipContains) {
            ok =  NO;
            error = [NSError errorWithDomain:SSYMoreFileManagerErrorDomain
                                        code:617014
                                    userInfo:@{NSLocalizedDescriptionKey: @"The given path is in a Autosave Information directory (probably a OS X legacy)"}] ;
        }
    }

    NSURL* temporaryUrl ;
    if (ok) {
        // Unfortunately, NSSearchPathDirectory does not offer an
        // NSTemporaryDirectory, so we use the path, and only in the Home
        // directory (the "user" domain), with or without the "/private" symlink
        temporaryUrl = [NSURL fileURLWithPath:NSTemporaryDirectory()] ;
        [fm getRelationship:&relationship
           ofDirectoryAtURL:temporaryUrl
                toItemAtURL:url
                      error:NULL] ;
        if (relationship == NSURLRelationshipContains) {
            ok =  NO;
            error = [NSError errorWithDomain:SSYMoreFileManagerErrorDomain
                                        code:617015
                                    userInfo:@{NSLocalizedDescriptionKey: @"The given path is in a Temporary directory"}] ;
        }
    }

    if (ok) {
        temporaryUrl = [NSURL fileURLWithPath:[@"/private" stringByAppendingPathComponent:NSTemporaryDirectory()]] ;
        [fm getRelationship:&relationship
           ofDirectoryAtURL:temporaryUrl
                toItemAtURL:url
                      error:NULL] ;
        if (relationship == NSURLRelationshipContains) {
            ok =  NO;
            error = [NSError errorWithDomain:SSYMoreFileManagerErrorDomain
                                        code:617016
                                    userInfo:@{NSLocalizedDescriptionKey: @"The given path is in /private/"}] ;
        }
    }

    if (ok) {
        if ([path length] < 1) {
            ok =  NO;
            error = [NSError errorWithDomain:SSYMoreFileManagerErrorDomain
                                        code:617017
                                    userInfo:@{NSLocalizedDescriptionKey: @"The given path is too short"}] ;
        }
    }
    
    if (error && error_p) {
        *error_p = error ;
    }

    return ok ;
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
	__block BOOL ok = YES ;
    __block NSError* error = nil;

    if (path) {
        if (scriptFinder) {
            NSString* source = [NSString stringWithFormat:
                                /**/@"with timeout 15 seconds\n"
                                /**/  @"tell application \"Finder\"\n"
                                /**/	@"delete POSIX file \"%@\"\n"
                                /**/  @"end tell\n"
                                /**/@"end timeout\n",
                                path] ;
            [SSYAppleScripter executeScriptSource:source
                                  ignoreKeyPrefix:nil
                                         userInfo:nil
                             blockUntilCompletion:YES
                                completionHandler:^(id  _Nullable payload, id  _Nullable userInfo, NSError * _Nullable scriptError) {
                                    if (scriptError) {
                                        ok = NO;
                                        error = SSYMakeError(572286, @"Finder refused to trash path") ;
                                        error = [error errorByAddingUnderlyingError:scriptError];
                                        [error retain];
                                    }
                                }];
            [error autorelease];
        } else {
            NSArray* urls = @[[NSURL fileURLWithPath:path]] ;
            /* Method -recycleURLs:completionHandler is very strange.  From its
             documentation

             "you must call the recycleURLs:completionHandler: method from a block
             running on an active dispatch queue; your completion handler block
             is subsequently executed on the same dispatch queue."

             That seems to mean that any attempt pause this thread while waiting
             for the completion handler to complete and assign `error` would
             result in deadlock.  This was corroborated by experiments.  I also
             tried to wrap it in an outer dispatch_async() but I could not get
             that to work without deadlock either.

             So that is why we pass completionHandler:NULL and just do not report
             errors when scriptFinder = NO :(  */
            [[NSWorkspace sharedWorkspace] recycleURLs:urls
                                     completionHandler:NULL] ;
        }
    } else {
        error = SSYMakeError(35262, @"Cannot trash nil path") ;
    }
	
	if (error && error_p) {
        error = [error errorByAddingUserInfoObject:path
                                            forKey:@"Path Attempted to Trash"];
        *error_p = error;
	}
    
	return ok ;
}

- (NSString*)ensureDesktopDirectoryNamed:(NSString*)dirName
                                 error_p:(NSError**)error_p {
    BOOL ok = YES;
    NSError* error = nil;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDesktopDirectory,  // or NSLibraryDirectory
                                                         NSUserDomainMask,
                                                         YES
                                                         ) ;
    NSString* path = ([paths count] > 0) ? [paths objectAtIndex:0] : nil ;
    if (!path) {
        ok = NO;
        error = [NSError errorWithDomain:SSYMoreFileManagerErrorDomain
                                    code:617005
                                userInfo:@{NSLocalizedDescriptionKey: @"Weird: Could not find ~/Desktop"}];
    }

    BOOL needsCreation = NO;
    if (ok) {
        path = [path stringByAppendingPathComponent:dirName];

        BOOL dirIsDir;
        BOOL dirExists = [[NSFileManager defaultManager] fileExistsAtPath:path
                                                              isDirectory:&dirIsDir];
        if (dirExists) {
            if (!dirIsDir) {
                ok = [[NSFileManager defaultManager] removeItemAtPath:path
                                                                error:&error];
                needsCreation = YES;
            }
        } else {
            needsCreation = YES;
        }
    }

    if (ok) {
        if (needsCreation) {
            ok = [[NSFileManager defaultManager] createDirectoryAtPath:path
                                           withIntermediateDirectories:YES
                                                            attributes:nil
                                                                 error:&error];
        }
    }

    if (!ok) {
        path = nil;
    }

    if (error && error_p) {
        *error_p = error ;
    }

    return path;
}


@end
