#import "NSError+SuggestMountVolume.h"
#import "NSString+MorePaths.h"
#import "NSError+InfoAccess.h"

@implementation NSError (SuggestMountVolume)

- (NSError*)maybeAddMountVolumeRecoverySuggestion {
	NSError* error = self ;
	NSString* path = [[self userInfo] objectForKey:@"Path"] ;
	NSString* volumePath = [path volumePath] ;
	if (volumePath) {
		if (![[NSFileManager defaultManager] fileExistsAtPath:volumePath]) {
			NSString* msg = [NSString stringWithFormat:
							 @"Mount the volume '%@'",
							 [[volumePath pathComponents] objectAtIndex:2]] ;
			error = [self errorByAddingLocalizedRecoverySuggestion:msg] ;
		}
	}
	
	return error ;
}

@end
