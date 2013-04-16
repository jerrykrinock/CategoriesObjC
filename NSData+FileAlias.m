#import "NSData+FileAlias.h"
#import "NSError+InfoAccess.h"
#import "NSError+MyDomain.h"
#import "NSError+LowLevel.h"
#import "SSYShellTasker.h"
#import "NSBundle+HelperPaths.h"
#import "NSKeyedUnarchiver+CatchExceptions.h"

//#import "DebugGuy.h"
//extern id debugGuyObject ;



__attribute__((visibility("default"))) NSString* const NSDataFileAliasAliasRecord = @"aliasRecord" ;
__attribute__((visibility("default"))) NSString* const NSDataFileAliasPath = @"path" ;
__attribute__((visibility("default"))) NSString* const NSDataFileAliasError = @"error" ;


NSString* const NSDataFileAliasWorkerName = @"FileAliasWorker" ;

#if 0
@interface SSYAliasResolver : NSObject {
	
}


@end

@implementation SSYAliasResolver


- (id) init {
	self = [super init];
	if (self != nil) {
//		NSMutableDictionary* info = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
		
		
		[NSThread detachNewThreadSelector:@selector(resolveAlias:)
								 toTarget:self
							   withObject:info] ;
		
	}
	return self;
}

- (NSString*)resolveAlias:(AliasHandle)handle {
	OSErr osErr = FSResolveAlias(NULL,
								 (AliasHandle)handle,
								 &resolvedFSRef,
								 &changed) ;
	
}
@end
#endif


@implementation NSData (FileAlias)

+ (NSData*)aliasRecordFromPath:(NSString*)path {
	if ([path length] == 0) {
		return nil ;
	}
	
	const char* pathC = [path fileSystemRepresentation] ;
	
	OSErr osErr ;
	AliasHandle aliasHandle = NULL ;
	osErr = FSNewAliasFromPath (
								NULL,
								pathC,
								0,
								&aliasHandle,
								NULL
								) ;

	NSData* data = nil ;
	if (
		(osErr == noErr)
		// ... File exists and we have a full alias
		||
		((osErr == fnfErr) && (aliasHandle != NULL))
		// ... File does not exist and we have a minimal alias
		) {
		
		Size size = GetAliasSize(aliasHandle) ;
		
		data = [NSData dataWithBytes:*aliasHandle
							  length:size] ;
	}
	
	return data ;
}

- (AliasHandle)aliasHandle {
  unsigned short nBytesAliasRecord ;
	/* 
	 In Aliases.h, note that the AliasRecord struct is opaque if 
	 MAC_OS_X_MIN_VERSION_REQUIRED >= MAC_OS_X_VERSION_10_4.  In other 
	 words, if the "Mac OS X Deployment Target" setting for your project is 
	 10.4 or later, the AliasRecord struct is opaque.
	 
	 That's because AliasRecords, as you've noticed, get written to disk but 
	 are also referenced in data, which means that they often have to be 
	 big-endian even on little-endian systems.  Rather than enumerate the 
	 cases in which you'd want big- or little-endian AliasRecords, we made 
	 the data type opaque and added new APIs which deal in native-endian 
	 data.  They're Get/SetAliasUserType and GetAliasSize, and there are 
	 also FromPtr versions of each if you have an AliasRecord * instead of 
	 an AliasHandle. 
	 
	 Eric Albert, Apple */ 
	
	nBytesAliasRecord = GetAliasSizeFromPtr((AliasPtr)[self bytes]);
	
	AliasHandle handle ;
	
	// Move the now-decoded data into the Handle.
	if (PtrToHand([self bytes], (Handle*)&handle, nBytesAliasRecord) != noErr) {
		// I don't think PtrToHandle can fail with virtual memory.
		// This branch is probably just left over from the old days.
		NSLog(@"Internal Error 526-0917") ;
		return NULL ;
	}

	return handle ;
}

- (NSString*)pathFromAliasRecordWithTimeout:(NSTimeInterval)timeout
									error_p:(NSError**)error_p {
	NSDictionary* requestInfo = [NSDictionary dictionaryWithObject:self
															forKey:NSDataFileAliasAliasRecord] ;
	// Note: It is important that requestInfo and all of its keys and all
	// of its values be encodeable.  The only objects we put in there were
	// an NSString key and an NSData value.
	// Thus, we should be OK to do the following:
	NSData* requestData = [NSKeyedArchiver archivedDataWithRootObject:requestInfo] ;
	
	NSString* workerPath = [[NSBundle mainBundle] pathForHelper:NSDataFileAliasWorkerName] ;
	NSData* responseData = nil ;
	NSData* stderrData = nil ;
	NSError* taskError = nil ;
	NSInteger taskResult = [SSYShellTasker doShellTaskCommand:workerPath
													arguments:nil
												  inDirectory:nil
													stdinData:requestData
												 stdoutData_p:&responseData
												 stderrData_p:&stderrData
													  timeout:timeout
													  error_p:&taskError] ;
	
	NSError* error = nil ;
	NSString* path = nil ;
	
	if (!responseData) {
		error = SSYMakeError(59751, @"No stdout from helper") ;
		error = [error errorByAddingUserInfoObject:[NSNumber numberWithInteger:taskResult]
											forKey:@"task result"] ;
		error = [error errorByAddingUserInfoObject:stderrData
											forKey:@"stderr"] ;
		goto end ;
	}
	
	NSDictionary* responseInfo = [NSKeyedUnarchiver unarchiveObjectSafelyWithData:responseData] ;
	
	if (!responseInfo) {
		error = SSYMakeError(29170, @"Could not decode response from helper") ;
		goto end ;
	}
	
	path = [responseInfo objectForKey:NSDataFileAliasPath] ;
	if (!path) {
		NSError* helperError = [responseInfo objectForKey:NSDataFileAliasError] ;
		NSInteger errorCode = [helperError code] ;
		if (
			(errorCode == fnfErr) // Local file not found
			||
			(errorCode == nsvErr) // Remote file's volume not mounted and server not available
			) {
			// File referenced by our alias record does not exist at this time
			// We can still extract the expected path from the alias.
			AliasHandle handle = [self aliasHandle] ;
			OSErr osErr = FSCopyAliasInfo (
										   handle,
										   NULL,
										   NULL,
										   (CFStringRef*)&(path),
										   NULL,
										   NULL
										   ) ;
			
			if (osErr != noErr) {
				//NSLog(@"Extracted from minimal alias: path: %@", path) ;
				
				// There may be a bug in the above function.  If the alias is to
				// that of a nonexistent directory in the root, for example,
				//    /Yousers
				// Then the path returned will begin with two slashes.
				// To work around that,
				if ([path hasPrefix:@"//"]) {
					path = [path substringFromIndex:1] ;
				}
			}
			else {
				error = SSYMakeError(26108, @"Helper returned error") ;
				error = [error errorByAddingUnderlyingError:helperError] ;
			}
		}
		else {
			// This is an error we cannot work around
			error = SSYMakeError(26195, @"Helper returned error") ;
			error = [error errorByAddingUnderlyingError:helperError] ;
		}
	}

end:
	if (error_p) {
		error = [error errorByAddingUnderlyingError:taskError] ;
		*error_p = error ;
	}
	
	return  path ;
}

- (NSData*)resolveAliasWithInfo:(NSData*)requestData {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init] ;
	
	AliasHandle handle = NULL ;
    NSError* error = nil ;
	NSString* path = nil ;
	
	NSDictionary* requestInfo = [NSKeyedUnarchiver unarchiveObjectSafelyWithData:requestData] ;

	if(!requestInfo) {
		error = SSYMakeError(62608, @"Could not unarchive request") ;
		goto end ;
	}
	
	NSData* aliasRecord = [requestInfo objectForKey:NSDataFileAliasAliasRecord] ;
	if(!aliasRecord) {
		error = SSYMakeError(65838, @"No aliasRecord in request") ;
		goto end ;
	}
	
	handle = [aliasRecord aliasHandle] ;
	if (!handle) {
		error = SSYMakeError(26238, @"Could not create AliasHandle") ;
		goto end ;
	}
	
	// Try and resolve the alias
	Boolean changed ;
	FSRef resolvedFSRef;
	OSErr osErr = FSResolveAlias(NULL,
								 (AliasHandle)handle,
								 &resolvedFSRef,
								 &changed) ;
	
	if (osErr != noErr) {
		error = [NSError errorWithMacErrorCode:osErr] ;
		error = [error errorByAddingUserInfoObject:@"FSResolveAlias"
											forKey:@"Function"] ;
		goto end ;
	}
	
	// Alias was resolved.  Now get its path from resolvedFSRef
	char pathC[4096] ;
	OSStatus osStatus = FSRefMakePath(
									  &resolvedFSRef,
									  (UInt8*)pathC,
									  sizeof(pathC)
									  ) ;
	
	if (osStatus != noErr) {
		error = [NSError errorWithMacErrorCode:osStatus] ;
		error = [error errorByAddingUserInfoObject:@"FSRefMakePath"
											forKey:@"Function"] ;
		goto end ;
	}
	
	path = [NSString stringWithCString:pathC
							  encoding:NSUTF8StringEncoding] ;
	
	// The full path returned by FSRefMakePath will NOT have a trailing slash UNLESS
	// the path is the root, i.e. @"/".  In that case it will.  Thus, in order to return
	// a standard result to which "/Filename.ext" should be appended, we remove that:
	if ([path length] == 1) {
		path = @"" ;
	}
	
end:
	if (handle) {
		DisposeHandle((Handle)handle);
	}
	
	NSDictionary* returnInfo = nil ;
	if (path) {
		returnInfo = [NSDictionary dictionaryWithObject:path
												 forKey:NSDataFileAliasPath] ;
	}
	else if (error) {
		returnInfo = [NSDictionary dictionaryWithObject:error
												 forKey:NSDataFileAliasError] ;
	}
	else {
		NSLog(@"Internal Error 267-1857") ;
	}
	
	// Note: It is important that returnInfo and all of its keys and all
	// of its values be encodeable.  The only objects we put in there were
	// NSString, and NSError whose userInfo dictionary contains only NSString
	// keys and values.  Thus, we should be OK to do the following:
	NSData* returnData = nil ;
    if (returnInfo) {
        [NSKeyedArchiver archivedDataWithRootObject:returnInfo] ;
    }
	
	[returnData retain] ;
	[pool drain] ;
	
	return [returnData autorelease] ;
}


@end