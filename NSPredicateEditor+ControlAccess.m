#import "NSPredicateEditor+ControlAccess.h"


@implementation NSPredicateEditor (ControlAccess)

- (void)removeAllRows {
	NSInteger nExcessRows = [self numberOfRows] ;
	
	NSRange range = NSMakeRange(0, nExcessRows) ;
	NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:range] ;
	[self removeRowsAtIndexes:indexSet
			   includeSubrows:YES] ;
}


- (NSView*)controlViewForRow:(NSInteger)row {
	return [[[[self subviews] objectAtIndex:0] subviews] objectAtIndex:row] ;
}

- (NSArray*)subviewsInRow:(NSInteger)row {
	return [[self controlViewForRow:row] subviews] ;
}

- (NSArray*)viewsOfClass:(Class)class
				   inRow:(NSInteger)row {
	NSMutableArray* array = [[NSMutableArray alloc] init] ;
	for (NSView* view in [[self controlViewForRow:row] subviews]) {
		if ([view isKindOfClass:class]) {
			[array addObject:view] ;
		}
	}
	
	// Note: -[NSView compareLeftEdges] is in the category NSView (Layout)
	NSArray* answer = [array sortedArrayUsingSelector:@selector(compareLeftEdges:)] ;
	[array release] ;
	
	return answer ;
}

- (NSControl*)controlOfClass:(Class)class
					fromLeft:(NSInteger)fromLeft
					   inRow:(NSInteger)row {
	NSArray* targetControls = [self viewsOfClass:class
										   inRow:row] ;
	NSPopUpButton* answer ;
	if([targetControls count] > fromLeft) {
		answer = [targetControls objectAtIndex:fromLeft] ;
	}
	else {
		answer = nil ;
	}
	
	return answer ;
}

@end
