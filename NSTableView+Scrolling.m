#import "NSTableView+Scrolling.h"

@implementation NSTableView (Scrolling)

- (void)scrollRowToTop:(NSInteger)row {
	if ((row != NSNotFound) && (row >=0)) {
		CGFloat rowPitch = [self rowHeight] + [self intercellSpacing].height ;
        /*  I don't understand why we need to subtract 1 from row in the next
         statement.  But if we don't, passing row=0 will make visible the
         second row instead of the first row, and so on. */
        CGFloat y = (row - 1) * rowPitch -1.0 ;
        [self scrollPoint:NSMakePoint(0, y)] ;
	}
}

@end