#import "NSTableView+Scrolling.h"

@implementation NSTableView (Scrolling)

- (void)scrollRowToTop:(NSInteger)row {
	if ((row != NSNotFound) && (row >=0)) {
		CGFloat rowPitch = [self rowHeight] + [self intercellSpacing].height ;
		CGFloat y = row * rowPitch ;
		[self scrollPoint:NSMakePoint(0, y)] ;
	}
}

@end