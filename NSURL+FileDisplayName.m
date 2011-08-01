#import "NSURL+FileDisplayName.h"


@implementation NSURL (FileDisplayName) 

- (NSString*)fileDisplayName {
	return [[[self path] lastPathComponent] stringByDeletingPathExtension] ;
}

@end

