#import "NSArray+Integers.h"


@implementation NSArray (Integers)

+ (NSArray*)arrayWithRange:(NSRange)range {
	NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:range.length] ;
	NSInteger i ;
	for (i=range.location; i<(range.location + range.length); i++) {
		[array addObject:[NSNumber numberWithInteger:i]] ;
	}
	
	NSArray* answer = [[array copy] autorelease] ;
	[array release] ;
	
	return answer ;
}

@end
