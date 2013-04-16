#import "NSFileManager+SomeMore.h"
#import "NSError+InfoAccess.h"
#import "NSError+MyDomain.h"
#import "NSError+LowLevel.h"
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

- (BOOL)getFromUrl:(NSURL*)url
		   fsRef_p:(FSRef*)fsRef_p
		   error_p:(NSError**)error_p {
	OSStatus err = paramErr ;

	NSString* path = nil ;
	if (url) {
		path = [url path] ;
	}
	if (path) {
		err = FSPathMakeRef(
							(UInt8*)[path fileSystemRepresentation],
							fsRef_p,
							NULL) ;
	}
	
	if (error_p) {
		if (err == noErr) {
			*error_p = nil ;
		}
		else {
			NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"Could not get FSRef", NSLocalizedDescriptionKey,
								  [url description], @"url",
								  [NSError errorWithMacErrorCode:err], NSUnderlyingErrorKey,
								  nil] ;
			*error_p = [NSError errorWithDomain:SSYMoreFileManagerErrorDomain
										   code:617001
									   userInfo:info] ;
		}
	}
	
	return (err == noErr) ;
}

- (BOOL)swapUrl:(NSURL*)url1
		withUrl:(NSURL*)url2
		 error_p:(NSError**)error_p {
	FSRef fsRef1, fsRef2 ;
	BOOL ok ;

	ok = [self getFromUrl:url1
				  fsRef_p:&fsRef1
				  error_p:error_p] ;
	if (!ok) {
		goto end ;
	}
	
	ok = [self getFromUrl:url2
				  fsRef_p:&fsRef2
				  error_p:error_p] ;
	if (!ok) {
		goto end ;
	}
	
	OSErr err = FSExchangeObjects (
								   &fsRef1,
								   &fsRef2
								   ) ;
	ok = (err == noErr) ;
	if (error_p) {
		if (err == noErr) {
			*error_p = nil ;
		}
		else {
			NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"Could not exchange FSRefs", NSLocalizedDescriptionKey,
								  [url1 description], @"url1",
								  [url2 description], @"url2",
								  [NSError errorWithMacErrorCode:err], NSUnderlyingErrorKey,
								  nil] ;
			*error_p = [NSError errorWithDomain:SSYMoreFileManagerErrorDomain
										   code:617002
									   userInfo:info] ;
		}
	}

	
	
end:
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
#if (MAC_OS_X_VERSION_MIN_REQUIRED < 1050) 
	NSDictionary* fileAttributes = [self fileAttributesAtPath:path
												 traverseLink:YES] ;
#else
	NSDictionary* fileAttributes = [self attributesOfItemAtPath:path
														  error:NULL] ;
#endif

	return [fileAttributes objectForKey:NSFileModificationDate] ;
}	

- (BOOL)createDirectoryIfNoneExistsAtPath:(NSString*)path
								  error_p:(NSError**)error_p {
	NSError* error = nil ;
	
	NSFileManager* fileManager = [NSFileManager defaultManager] ;
	BOOL isDirectory ;
	BOOL exists = [fileManager fileExistsAtPath:path
									isDirectory:&isDirectory] ;
	
	BOOL ok = YES ;
    // Next line has bug fixed in BookMacster 1.13.6.  Prior to this, it was
    // simply if(!isDirectory), which passed and created an error if neither
    // file nor directory existed at path.
	if (exists && !isDirectory) {
		ok = [fileManager removeItemAtPath:path
									 error:&error] ;
		if (!ok) {
			error = [SSYMakeError(35261, @"Could not remove file") errorByAddingUnderlyingError:error] ;
			[error errorByAddingUserInfoObject:path
										forKey:@"path"] ;
		}
	}
	if (!exists) {
		ok = [fileManager createDirectoryAtPath:path
					withIntermediateDirectories:YES
									 attributes:nil
										  error:&error] ;
	}
	
	if (error && error_p) {
		*error_p = error ;
	}
	
	return ok ;
}

- (BOOL)fileIsPermanentAtPath:(NSString*)path {	
	
	// The ^correct^ way to find if a path is in a temporary folder should
	// be to pass its FSRef along with kTemporaryFolderType to
	// FSDetermineIfRefIsEnclosedByFolder().  I have done this farther down,
	// but it "just doesn't work" to find paths which are in the
	// temporary directory that Cocoa uses, something like:
	//    /private/var/folders/PR/PRtZlutkFa82jPnfdYcUUk+++TI/-Tmp-/
	// So, to work around that I first get the current ^Cocoa^ temporary
	// directory and see if the given path is in there, with or without the
	// "/private" symbolic link
	NSString* cocoaTempDir = NSTemporaryDirectory() ;
	if ([path hasPrefix:cocoaTempDir]) {
		return NO ;
	}
	cocoaTempDir = [@"/private" stringByAppendingPathComponent:cocoaTempDir] ;
	if ([path hasPrefix:cocoaTempDir]) {
		return NO ;
	}
	
	FSRef fsRef;
	OSStatus err = paramErr ;
	if (path) {
		err = FSPathMakeRef(
							(UInt8*)[path fileSystemRepresentation],
							&fsRef,
							NULL) ;
	}
	
	if (err == noErr) {
		Boolean result ;
		
		// Note: FSDetermineIfRefIsEnclosedByFolder will return a -35 nsvErr
		// (no such volume) if the fsRef given in the third argument is not
		// in the specified folder.  Probably that is because it is iterating
		// through all possible volumes that match the specification given in the
		// first parameter, 0, which means "all volumes", and the last one it tried
		// was something that didn't exist, maybe an OS9/Classic volume.
		// Seems like a bug to me.  But anyhow, we ignore it.
		FSDetermineIfRefIsEnclosedByFolder (
											0,
											kTrashFolderType,
											&fsRef,
											&result
											) ;
		if (result == true) {
			return NO ;
		}
		
		FSDetermineIfRefIsEnclosedByFolder (
											0,
											kTemporaryFolderType,
											&fsRef,
											&result
											) ;
		if (result == true) {
			return NO ;
		}
		
		FSDetermineIfRefIsEnclosedByFolder (
											0,
											kWhereToEmptyTrashFolderType,
											&fsRef,
											&result
											) ;
		if (result == true) {
			return NO ;
		}
		
		FSDetermineIfRefIsEnclosedByFolder (
											0,
											kTemporaryItemsInCacheDataFolderType,
											&fsRef,
											&result
											) ;
		if (result == true) {
			return NO ;
		}
		
        FSDetermineIfRefIsEnclosedByFolder (
											0,
											kChewableItemsFolderType,
											&fsRef,
											&result
											) ;
		if (result == true) {
			return NO ;
		}
		
		// See if it's in the "Dropbox trash"
		NSArray* components = [path pathComponents] ;
		if ([components indexOfObject:@".dropbox.cache"] != NSNotFound) {
			return NO ;
		}
	}
	else {
		return NO ;
	}
	
	return YES ;
}

- (BOOL)fsGetCatalogInfo_p:(FSCatalogInfo*)catInfo_p
			  whichInfo:(FSCatalogInfoBitmap)whichInfo
				  fsRef:(FSRef)pathRef
				error_p:(NSError**)error_p {
    OSErr osErr;
	
    osErr = FSGetCatalogInfo(
							 &pathRef,
							 whichInfo,
							 catInfo_p,
							 NULL,
							 NULL,
							 NULL
							 ) ;
	
	if (osErr != noErr) {
		if (error_p) {
			NSError* error_ = [NSError errorWithMacErrorCode:osErr] ;
			*error_p = SSYMakeError(65840, @"FSGetCatalogInfo failed") ;
			*error_p = [*error_p errorByAddingUnderlyingError:error_] ;
		}
		
		return NO ;
	}
    
	return YES ;
}

- (BOOL)fsSetCatalogInfo:(FSCatalogInfo)catInfo
			   whichInfo:(FSCatalogInfoBitmap)whichInfo
				   fsRef:(FSRef)pathRef
				 error_p:(NSError**)error_p {
    OSErr osErr;
	osErr = FSSetCatalogInfo(
							 &pathRef,
							 whichInfo,
							 &catInfo
							 ) ;
	
	if (osErr != noErr) {
		if (error_p) {
			NSError* error_ = [NSError errorWithMacErrorCode:osErr] ;
			*error_p = SSYMakeError(65840, @"FSSetCatalogInfo failed") ;
			*error_p = [*error_p errorByAddingUnderlyingError:error_] ;
		}
		
		return NO ;
	}
	
	return YES ;
}

- (BOOL)fsGetCatalogInfo_p:(FSCatalogInfo*)catInfo_p
				 whichInfo:(FSCatalogInfoBitmap)whichInfo
				   path:(NSString*)path
				error_p:(NSError**)error_p {
	FSRef pathRef;	
    // Warning: FSPathMakeRef may hang for a minute or so if mounted server is interrupted
	FSPathMakeRef(
				  (UInt8*)[path fileSystemRepresentation],
				  &pathRef,
				  NULL
				  ) ;
	
    NSError* error = nil ;
	BOOL ok = [self fsGetCatalogInfo_p:catInfo_p
							 whichInfo:whichInfo
							  fsRef:pathRef
							error_p:&error] ;
	if (!ok) {
		if (error_p) {
			*error_p = error ;
			*error_p = [*error_p errorByAddingUserInfoObject:path
													  forKey:@"path"] ;

			return NO ;
		}
	}
	
	return YES ;
}	

- (NSInteger)fileIsLockedAtPath:(NSString*)path
						error_p:(NSError**)error_p {
	NSError* error = nil  ;
	FSCatalogInfo catInfo ;
	BOOL ok = [self fsGetCatalogInfo_p:&catInfo
						  whichInfo:kFSCatInfoNodeFlags
							   path:path
							error_p:&error] ; 
	
	if (!ok) {
		if (error_p) {
			*error_p = SSYMakeError(65847, @"Could not determine if file is locked") ;
			*error_p = [*error_p errorByAddingUnderlyingError:error] ;
		}
		
		return NSMixedState ;
	}
    
	UInt16 nodeFlags = catInfo.nodeFlags ;
	return ((nodeFlags & kFSNodeLockedMask) > 0 ) ? NSOnState : NSOffState ;
}

- (BOOL)setDoLock:(BOOL)doLock
	   fileAtPath:(NSString*)path
		  error_p:(NSError**)error_p {	
	FSRef pathRef;	
    // Warning: FSPathMakeRef may hang for a minute or so if mounted server is interrupted
	FSPathMakeRef(
				  (UInt8*)[path fileSystemRepresentation],
				  &pathRef,
				  NULL
				  ) ;

    NSError* error = nil ;
    NSError* error_ = nil ;
	FSCatalogInfo catInfo ;
	BOOL ok ;
	
	ok= [self fsGetCatalogInfo_p:&catInfo
					   whichInfo:kFSCatInfoNodeFlags
						   fsRef:pathRef
						 error_p:&error_] ;
	
	if (!ok) {
		error = SSYMakeError(65842, @"Could not get catInfo needed to un/lock file") ;
		goto end ;
	}
	
	// Alter the 'node locked' bit of the flags
	UInt16 nodeFlags = catInfo.nodeFlags ;
	nodeFlags = doLock ? (nodeFlags | kFSNodeLockedMask) :  (nodeFlags & ~kFSNodeLockedMask) ;
	catInfo.nodeFlags = nodeFlags ;
	
	ok = [self fsSetCatalogInfo:catInfo
					  whichInfo:kFSCatInfoNodeFlags
						  fsRef:pathRef
						error_p:&error_] ;
	
	if (!ok) {
		error = SSYMakeError(65848, @"Could not set un/lock file") ;
		goto end ;
	}

end:
	if (!ok) {
		if (error_p) {
			*error_p = [error errorByAddingUnderlyingError:error_] ;
			*error_p = [*error_p errorByAddingUserInfoObject:(doLock ? @"lock" : @"unlock")
													  forKey:@"attempted operation"] ;
			*error_p = [*error_p errorByAddingUserInfoObject:path
													  forKey:@"path"] ;
		}
	}
	
	return ok ;
}

- (NSString*)pathToSpecialFolderType:(OSType)folderType {
	FSRef foundRef ;
	OSErr err = FSFindFolder (
							  kUserDomain,
							  folderType,
							  false,
							  &foundRef ) ;
	char fullPath[1024];
  	if (err == noErr) {
		OSStatus osStatus = FSRefMakePath (&foundRef, (UInt8*)fullPath, sizeof(fullPath)) ;
		if (osStatus != noErr) {
			err = 1 ;
		}
	}
	
	NSString* path = nil ;
	if (err == noErr) {		
		path = [NSString stringWithCString:fullPath
								  encoding:NSUTF8StringEncoding] ;
	}
	
	return path ;
}

- (BOOL)fcntlIsLockedAtPath:(NSString*)path {
	/* I haven't studied all the details of this.  It's patterned after
	 JavaScript code found in the source code by Jonathan Griffin
	 for the (Firefox) ProfileManager project:
	 http://jagriffin.wordpress.com/2011/01/11/profilemanager-1-0_beta1/
	 source code: http://hg.mozilla.org/automation/profilemanager/
	 in the file chrome/content/utils.js:177
	 function isFcntlLocked(file).
	 
	 Here is Jonathan's description:
	 Determines if a profile lockfile is locked with fcntl.  This is done by
	 attempting to lock the file; if we can, it isn't locked by something else.
	 */	 	 
	BOOL isLocked = NO ;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path] ;
	if (exists) {
		const char* pathC = [path UTF8String] ;
		NSInteger fd = open(
					  pathC,
					  FREAD | O_CREAT | O_TRUNC,
					  S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH) ;
		struct flock daFlock ;
		daFlock.l_start = 0 ;
		daFlock.l_len = 0 ;
		daFlock.l_type = F_WRLCK ;
		daFlock.l_whence = SEEK_SET ;
		
		// Jonathan says: Attempt to get lock status; if this
		// returns -1 it means fcntl isn't supported on this file
		NSInteger getlock = fcntl(fd, F_GETLK, &daFlock) ;
		
		if (getlock != -1) {
			// Attempt to lock the file
			NSInteger setlock = fcntl(fd, F_SETLK, &daFlock) ;
			if (setlock == -1) {
				// Attempt to lock the file failed
				if (errno == EAGAIN || errno == EACCES) {
					isLocked = YES ;
				}
			}
		}
		close(fd) ;
	}		
	
	return isLocked ;
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
	NSError* error = nil ;
	
	BOOL ok = YES ;
	if (scriptFinder) {
		NSString* source = [NSString stringWithFormat:
							/**/@"tell application \"Finder\"\n"
							/**/	@"delete POSIX file \"%@\"\n"
							/**/@"end tell\n",
							path] ;
		NSAppleScript* script = [[NSAppleScript alloc] initWithSource:source];
		NSDictionary* errorDic = nil ;
		[script executeAndReturnError:&errorDic] ;
		[script release] ;
		if (errorDic) {
			ok = NO ;
			error = [NSError errorWithAppleScriptErrorDictionary:errorDic] ;
		}
	}
	else {
		const char* pathC = [path fileSystemRepresentation] ;
		OSStatus status = FSPathMoveObjectToTrashSync (
													   pathC,
													   NULL,
													   (kFSFileOperationOverwrite | kFSFileOperationSkipSourcePermissionErrors)
													   ) ;
		if (status != noErr) {
			ok = NO ;
			error = SSYMakeError(572287, @"Could not trash path") ;
			error = [error errorByAddingUserInfoObject:path
												forKey:@"Path"] ;
			error = [error errorByAddingUserInfoObject:[NSNumber numberWithLong:status]
												forKey:@"OSStatus"] ;
		}
	}
	
	if (error_p && error) {
		*error_p = [error errorByAddingUserInfoObject:path
											   forKey:@"Path Attempted to Trash"] ;		
	}
	
	return ok ;
}


@end