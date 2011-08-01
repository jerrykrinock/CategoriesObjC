#import "NSArray+Indexing.h"
#import "SSYIndexee.h"

@implementation NSArray (Indexing)

- (void)fixIndexesContiguousStartingAtIndex:(NSInteger)index {
	for (NSInteger i=index; i<[self count]; i++) {
		[(NSObject <SSYIndexee> *)[self objectAtIndex:i] setIndex:[NSNumber numberWithInteger:i]] ;
	}
}

@end
