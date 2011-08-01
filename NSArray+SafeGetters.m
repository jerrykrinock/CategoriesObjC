#import "NSArray+SafeGetters.h"


@implementation NSArray (SafeGetters)

- (id)firstObjectSafely {
	id answer = nil ;
	
	if ([self count] > 0) {
		answer = [self objectAtIndex:0] ;
	}
	
	return answer ;
}

- (id)lastObjectSafely {
	id answer = nil ;
	
	int count = [self count] ;
	if (count > 0) {
		answer = [self objectAtIndex:(count-1)] ;
	}
	
	return answer ;
}

- (id)objectSafelyAtIndex:(int)index {
	id answer = nil ;
	
	if ((index >= 0) && (index < [self count])) {
		answer = [self objectAtIndex:index] ;
	}
	
	return answer ;
}

@end
