#import "NSTableView+Scrolling.h"

@implementation NSTableView (Scrolling)

// Fix the fact that visibleRect includes top rows obscured by header
- (NSRect)visibleRowsRect {
    NSRect visibleRect = [self visibleRect] ;
    NSRect headerRect = [[self headerView] frame] ;
    NSRect clipRect = [[self superview] frame] ;
    CGFloat v = visibleRect.size.height ;
    CGFloat y = visibleRect.origin.y ;
    CGFloat H = headerRect.size.height ;
    CGFloat C = clipRect.size.height ;

    visibleRect.size.height = C - H ;

    if (y < 0.01) {
        // Case 1.
        visibleRect.origin.y = v - visibleRect.size.height ;
    }
    else {
        // Case 2.
        visibleRect.origin.y += H ;
    }
    


    
    return visibleRect ;
}

- (void)scrollRowToTop:(NSInteger)row
       plusExtraPoints:(CGFloat)extraPoints {
    CGFloat y = 0 ;
	if ((row != NSNotFound) && (row >=0)) {
		CGFloat rowPitch = [self rowHeight] + [self intercellSpacing].height ;
        y = -[[self headerView] frame].size.height ;
        y += (row) * rowPitch ;
        
        y += extraPoints ;
        
        [self scrollRowPoint:NSMakePoint(0, y)] ;
        // Above is o low-level method that scrolls Content, 1 of 2
	}
}

- (void)scrollRowPoint:(NSPoint)point {
    point.y -= [[self headerView] frame].size.height ;
    [self scrollPoint:point] ;
}

@end