#import "NSArray+Reversing.h"

@implementation NSArray (Reversing)

- (NSArray*)arrayByReversingOrder {
	NSMutableArray* array = [[NSMutableArray alloc] init] ;
	for (id object in self) {
		[array insertObject:object
				 atIndex:0] ;
	}
	
	NSArray* output = [array copy] ;
	[array release] ;
	
	return [output autorelease] ;
}


@end
