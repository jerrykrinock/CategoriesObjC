#import "NSFileHandle+SSYExtras.h"


@implementation NSFileHandle (SSYExtras)

+ (NSFileHandle*)clearateFileHandleForWritingAtPath:(NSString*)path {
	NSFileManager* fileManager = [NSFileManager defaultManager] ;
	NSFileHandle* fileHandle = nil ;
	if ([fileManager fileExistsAtPath:path]) {
		fileHandle = [NSFileHandle fileHandleForWritingAtPath:path] ;
		[fileHandle truncateFileAtOffset:0LL] ;
	}
	else {
		[fileManager createFileAtPath:path
							 contents:[NSData data]
						   attributes:nil] ;
		fileHandle = [NSFileHandle fileHandleForWritingAtPath:path] ;		
	}
	
	return fileHandle ;
}

@end
