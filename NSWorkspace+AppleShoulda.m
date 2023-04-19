#import "NSWorkspace+AppleShoulda.h"
#import "SSYUserInfo.h"

@implementation NSWorkspace (AppleShoulda)

+ (NSString*)appNameForBundleIdentifier:(NSString*)bundleIdentifier {
	NSWorkspace* workspace = [self sharedWorkspace] ;
	NSString* path = [[workspace URLForApplicationWithBundleIdentifier:bundleIdentifier] absoluteString];
	NSBundle* bundle = [NSBundle bundleWithPath:path] ;
	NSString* appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"] ;
	
	// Added in BookMacster version 1.3.22
	if (bundle) {
		if ([appName length] == 0) {
			NSLog(@"Warning 562-0981.  No CFBundleName in %@", bundleIdentifier) ;
			appName = [bundle objectForInfoDictionaryKey:@"CFBundleExecutable"] ;
			if ([appName length] == 0) {
				NSLog(@"Warning 562-0982.  No CFBundleExecutable in %@", bundleIdentifier) ;
				appName = [bundleIdentifier lastPathComponent] ;
			}
		}
	}
	
	return appName ;
}

- (NSArray*)mountedLocalVolumeNames {
	NSString* path = @"/Volumes" ;
	NSFileManager* fileManager = [NSFileManager defaultManager] ;
#if (MAC_OS_X_VERSION_MIN_REQUIRED < 1050) 
#pragma deploymate push "ignored-api-availability" // Skip it until next "pop"
	NSArray* volumes = [fileManager directoryContentsAtPath:path] ;
#pragma deploymate pop
#else
	NSArray* volumes = [fileManager contentsOfDirectoryAtPath:path
														error:NULL] ;
#endif

	// Filter volumes to remove hidden volumes, and those which we cannot execute (execute=look inside)
	NSMutableArray* filteredVolumes = [NSMutableArray array] ;
	uid_t userID ;
	uid_t groupID ;
	[SSYUserInfo consoleUserNameAndUid_p:&userID
								   gid_p:&groupID] ;
	for (NSString* volume in volumes) {
		if (![volume hasPrefix:@"."]) {
			BOOL canX;
			canX = YES ;
			
			if (canX) {
				[filteredVolumes addObject:volume] ;
			}
		}		
	}
	
	return filteredVolumes ;
	// Note: There is a "Cocoa way" to get the mounted volumes:
	// NSLog(@"volumes using NSWorkspace:\n%@", [[NSWorkspace sharedWorkspace] mountedLocalVolumePaths]) ;
	// NSLog(@"volumes using my method:\n%@", volumes) ;
	// But it gives slightly different results, not giving the name of the startup volume:
	/*
	 2009-06-27 07:15:26.528 BookMacster[20194:10b] volumes using NSWorkspace:
	 (
	 "/",
	 "/Volumes/Spare",
	 "/Volumes/JTimeHD",
	 "/Volumes/r"
	 )
	 2009-06-27 07:15:26.529 BookMacster[20194:10b] volumes using my method:
	 (
	 JMiniHD,
	 JTimeHD,
	 r,
	 Spare
	 )
	 */		 
}

@end
