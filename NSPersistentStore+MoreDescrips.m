#import "NSPersistentStore+MoreDescrips.h"


@implementation NSPersistentStore (MoreDescrips)

- (NSString*)longDescription {
	NSString* type = [self type] ;
	NSString* path = [[self URL] path] ;
	NSString* desc = [NSString stringWithFormat:
					  @"<%@ %@>",
					  type ? type : @"nil-store-type",
					  path ? path : @"nil-store-path"] ;
	return desc ;
}

@end
