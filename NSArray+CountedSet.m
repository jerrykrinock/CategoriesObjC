#import "NSArray+CountedSet.h"


@implementation NSArray (CountedSet)

- (NSCountedSet*)countedSet {
	return [[[NSCountedSet alloc] initWithArray:self] autorelease] ;
}

@end
