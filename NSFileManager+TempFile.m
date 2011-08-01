#import "NSFileManager+TempFile.h"
#import "SSYUuid.h"

@implementation NSFileManager (TempFile)

- (NSURL*)temporarySiblingForFileUrl:(NSURL*)fileUrl {
	NSString* path = [fileUrl path] ;
	do {
		path = [path stringByAppendingPathExtension:@"temp"] ;
	} while ([self fileExistsAtPath:path]) ;
	
	return [NSURL fileURLWithPath:path] ;
}

- (NSString*)temporaryFilePath {
	NSString* tempFilename = [NSString stringWithFormat:
							  @"%@|%@",
							  [[NSProcessInfo processInfo] processName],
							  [SSYUuid compactUuid]] ;
	NSString* tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:tempFilename] ;
	
	return tempPath ;
}

@end
