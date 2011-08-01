#import "NS(Attributed)String+Geometrics.h"


@implementation NSSegmentedControl (FitTextNice)

- (void)fitTextNice {
	int N = [self segmentCount] ;
	int i ;

	float totalWidthAvailable = 0.0 ;
	for (i=0; i<N; i++) {
		totalWidthAvailable += [self widthForSegment:i] ;
	}
	
	float totalTextWidth = 0.0 ;
	NSMutableArray* textWidths = [[NSMutableArray alloc] init] ;
	for (i=0; i<N; i++) {
		float textWidth = [[self labelForSegment:i] widthForHeight:FLT_MAX
															  font:[self font]] ;
		[textWidths addObject:[NSNumber numberWithFloat:textWidth]] ;
		totalTextWidth += textWidth ;
	}
		 
	float factor = totalWidthAvailable/totalTextWidth ;

	for (i=0; i<N; i++) {
		float textWidth = [[textWidths objectAtIndex:i] floatValue] * factor ;
		[self setWidth:textWidth
			forSegment:i] ;
	}
}

@end
