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
	[self createDirectoryAtPath:lockPath
					 attributes:nil] ;
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
	[self removeFileAtPath:removePath
				   handler:nil] ;
	removePath = [self syncServicesLockPathForPath:path] ;
	[self removeFileAtPath:removePath
				   handler:nil] ;
}


@end