#import "NSIndexSet+MoreRanges.h"


@implementation NSIndexSet (MoreRanges)

- (NSIndexSet*)indexesInRange:(NSRange)range {
	NSInteger max = range.location + range.length ;
	NSInteger priorIndex = range.location - 1 ;
	NSMutableIndexSet* newSet = [[NSMutableIndexSet alloc] init] ;
	while (YES) {
		NSInteger index ;
		// It seems to be an undocumented fact of -indexGreaterThanIndex: that
		// if the index parameter is < 0, the method returns NSNotFound.
		// We work around that with the following brancher:
		if (priorIndex < 0) {
			index = [self firstIndex] ;
		}
		else {
			index = [self indexGreaterThanIndex:priorIndex] ;
		}
		
		if (index == NSNotFound) {
			break ;
		}
		
		if (index > max) {
			break ;
		}
		
		[newSet addIndex:index] ;
		priorIndex = index ;
	}
	
	NSIndexSet* answer = [newSet copy] ;
	[newSet release] ;
	
	return [answer autorelease] ;
}



@end