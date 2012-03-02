#import "NSWorkspace+AppleShoulda.h"
#import "SSYUserInfo.h"
#import "SSYSuperFileManager.h"

@implementation NSWorkspace (AppleShoulda)

+ (NSString*)appNameForBundleIdentifier:(NSString*)bundleIdentifier {
	NSWorkspace* workspace = [self sharedWorkspace] ;
	NSString* path = [workspace absolutePathForAppBundleWithIdentifier:bundleIdentifier] ;
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

+ (NSString*)bundleIdentifierForAppName:(NSString*)appName  {
	NSWorkspace* workspace = [self sharedWorkspace] ;
	NSString* path = [workspace fullPathForApplication:appName] ;
	NSBundle* bundle = [NSBundle bundleWithPath:path] ;
	NSString* bundleIdentifier = [bundle bundleIdentifier] ;
	return bundleIdentifier ;
}

- (NSArray*)mountedLocalVolumeNames {
	NSString* path = @"/Volumes" ;
	SSYSuperFileManager* fileManager = [SSYSuperFileManager defaultManager] ;
#if (MAC_OS_X_VERSION_MAX_ALLOWED < 1060) 
	NSArray* volumes = [fileManager directoryContentsAtPath:path] ;
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
			NSString* fullPath = [path stringByAppendingPathComponent:volume] ;
			BOOL canX;
			canX = [fileManager canExecutePath:fullPath
									   groupID:groupID
										userID:userID] ;
			
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