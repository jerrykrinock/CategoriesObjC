#import "NSArray+Whitespace.h"

@implementation NSArray (Whitespace)

- (NSArray*)arrayByTrimmingWhitespaceFromStringsAndRemovingEmptyStrings {
	NSMutableArray* a = [[NSMutableArray alloc] init] ;
	NSCharacterSet* whitespaceSet = [NSCharacterSet whitespaceCharacterSet] ;
	for (NSString* oldString in self) {
		NSString* newString = [oldString stringByTrimmingCharactersInSet:whitespaceSet] ;
		if ([newString length] > 0) {
			[a addObject:newString] ;
		}
	}
	
	NSArray* output = [a copy] ;
	[a release] ;
	
	return [output autorelease] ;
}

@end