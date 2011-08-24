#import "NSFileManager+SyncServFaker.h"
#include <unistd.h>

@implementation NSFileManager (SyncServFaker)

- (NSString*)syncServicesLockPathForPath:(NSString*)path {
	return [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"lock"] ;
}

- (NSString*)syncServicesDetailsPathForPath:(NSString*)path {
	return [[self syncServicesLockPathForPath:path] stringByAppendingPathComponent:@"details.plist"] ;
}

- (BOOL)syncServicesHasLockedPath:(NSString*)path {
	NSString* lockPath = [self syncServicesDetailsPathForPath:path] ;
	BOOL isDirectory ;
	BOOL exists = [self fileExistsAtPath:lockPath
							 isDirectory:&isDirectory] ;
	NSData* data = [NSData dataWithContentsOfFile:lockPath] ;
	NSDictionary* lockDic = [NSPropertyListSerialization propertyListFromData:data
															 mutabilityOption:0
																	   format:NULL
															 errorDescription:NULL] ;
	if (!lockDic) {
		// Bad lock file.  Ignore it.
		return NO ;
	}
	else {

		NSNumber* lockPid = [lockDic objectForKey:@"LockFileProcessID"] ;
		if (!lockPid) {
			// Bad lock file.  Ignore it.
			return NO ;
		}
		int pid = [lockPid intValue] ;
		struct ProcessSerialNumber psn = {0, 0};
		GetProcessForPID (pid, &psn) ;
		if ((psn.highLongOfPSN == 0) && (psn.lowLongOfPSN == 0)){
			NSLog(@"Ignoring lock file set by terminated process with pid %d", pid) ;
			NSError* error = nil ;
			BOOL ok = [self removeItemAtPath:lockPath
									   error:&error] ;
			if (ok) {
				NSLog(@"and removed lock file") ;
			}
			else {
				NSLog(@"but could not remove lock file because %@", error) ;
			}
			
			return NO ;
		}

		NSDate* lockDate = [lockDic objectForKey:@"LockFileDate"] ;
		if (!lockDate) {
			// Bad lock file.  Ignore it.
			return NO ;
		}
		NSTimeInterval timeSinceLock = -[lockDate timeIntervalSinceNow] ;
		if (timeSinceLock > 60.0) {
			NSLog(@"Ignoring lock file %@ since it has been locked for %f seconds, too long!", lockPath, timeSinceLock) ;
			return NO ;
		}
	}

	return (exists && isDirectory) ;
}

- (BOOL)blockUntilSafeToWritePath:(NSString*)path
						  timeout:(NSTimeInterval)timeout {
	NSDate* startDate = [NSDate date] ;
	
	while (YES) {
		BOOL ok = ![self syncServicesHasLockedPath:path] ;
		
		if (ok) {
			return YES ;
		}
		else if ([startDate timeIntervalSinceNow] < -timeout) {
			return NO ;
		}
		
		usleep(500000) ;
	}
}

- (BOOL)acquireSyncServicesLockPath:(NSString*)path
							timeout:(NSTimeInterval)timeout {
	if (![self blockUntilSafeToWritePath:path
								 timeout:timeout]) {
		return NO ;
	}
	
	NSDictionary* lockDic = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSDate date], @"LockFileDate",
							 @"localhost", @"LockFileHostname",
							 [NSNumber numberWithInt:[[NSProcessInfo processInfo] processIdentifier]], @"LockFileProcessID",
							 [[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] lastPathComponent], @"LockFileProcessName",
							 NSFullUserName(), @"LockFileUsername",
							 nil] ;
	NSString* lockPath = [self syncServicesLockPathForPath:path] ;
	NSError* error = nil ;
	/*
	 If you are developing with the 10.5 SDK, MAC_OS_X_VERSION_MAX_ALLOWED = 1050, MAC_OS_X_VERSION_10_5 = 1050 and the following #if will be true.
	 If you are developing with the 10.6 SDK, MAC_OS_X_VERSION_MAX_ALLOWED = 1060, MAC_OS_X_VERSION_10_5 = 1050 and the following #if will be false.
	 */
#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5) 
	[self createDirectoryAtPath:lockPath
					 attributes:nil] ;
#else
	[self createDirectoryAtPath:lockPath
	withIntermediateDirectories:YES
					 attributes:nil
						  error:&error] ;
#endif
	if (error) {
		NSLog(@"Internal Error 248-0938 %@", error) ;
	}
	NSString* detailsPath = [self syncServicesDetailsPathForPath:path] ;
	NSData* data = [NSPropertyListSerialization dataFromPropertyList:lockDic
															  format:NSPropertyListXMLFormat_v1_0
													errorDescription:NULL] ;
	[data writeToFile:detailsPath
		   atomically:YES] ;
	
	return YES ;
}


- (void)relinquishSyncServicesLockPath:(NSString*)path {
	NSString* removePath ;
	removePath = [self syncServicesDetailsPathForPath:path] ;

#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5) 
	[self removeFileAtPath:removePath
				   handler:nil] ;
#else
	NSError* error = nil ;
	[self removeItemAtPath:removePath
					 error:&error] ;
	if (error) {
		NSLog(@"Internal Error 345-9678 %@", error) ;
	}
	error = nil ;
#endif

	removePath = [self syncServicesLockPathForPath:path] ;
#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5) 
	[self removeFileAtPath:removePath
				 handler:nil] ;
#else
	[self removeItemAtPath:removePath
				   error:&error] ;
	if (error) {
		NSLog(@"Internal Error 194-8497 %@", error) ;
	}
#endif
}


@end