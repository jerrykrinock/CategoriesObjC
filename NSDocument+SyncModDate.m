#import "NSDocument+SyncModDate.h"


@implementation NSDocument (SyncModDate)

- (void)syncFileModificationDate {
	NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self fileURL] path]
																					error:NULL] ;
	NSDate* newModificationDate = [fileAttributes objectForKey:NSFileModificationDate] ;
	[self setFileModificationDate:newModificationDate] ;
}

@end
