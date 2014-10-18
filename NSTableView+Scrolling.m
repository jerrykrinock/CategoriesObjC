#import "NSTableView+Scrolling.h"

@implementation NSTableView (Scrolling)

- (void)scrollRowToTop:(NSInteger)row {
	if ((row != NSNotFound) && (row >=0)) {
		CGFloat rowPitch = [self rowHeight] + [self intercellSpacing].height ;
#warning Why do I need to fudge when scrolling to row 0?
        NSInteger fudgeRow = 0 ;
        CGFloat fudgePoints = 0 ;
        if (row == 0) {
            fudgeRow = -1 ;
            fudgePoints = -1.0 ;
        }
		CGFloat y = (row + fudgeRow) * rowPitch + fudgePoints ;
        [self scrollPoint:NSMakePoint(0, y)] ;
	}
}

@end