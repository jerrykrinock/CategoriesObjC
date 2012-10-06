#import "NS(Attributed)String+Geometrics.h"


@implementation NSSegmentedControl (FitTextNice)

- (void)fitTextNice {
	NSInteger N = [self segmentCount] ;
	NSInteger i ;

	CGFloat totalWidthAvailable = 0.0 ;
	for (i=0; i<N; i++) {
		totalWidthAvailable += [self widthForSegment:i] ;
	}
	
	CGFloat totalTextWidth = 0.0 ;
	NSMutableArray* textWidths = [[NSMutableArray alloc] init] ;
	for (i=0; i<N; i++) {
		CGFloat textWidth = [[self labelForSegment:i] widthForHeight:CGFLOAT_MAX
															  font:[self font]] ;
		[textWidths addObject:[NSNumber numberWithDouble:textWidth]] ;
		totalTextWidth += textWidth ;
	}
		 
	CGFloat factor = totalWidthAvailable/totalTextWidth ;

	for (i=0; i<N; i++) {
		CGFloat textWidth = [[textWidths objectAtIndex:i] doubleValue] * factor ;
		[self setWidth:textWidth
			forSegment:i] ;
	}
    
    [textWidths release] ;
}

@end
