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
    /*SSYDBL*/ NSLog(@"uncorr:   %@", NSStringFromRect(visibleRect)) ;
    /*SSYDBL*/ NSLog(@"v=%0.1f  y=%0.1f  H=%0.1f  C=%0.1f", v, y, H, C) ;

    visibleRect.size.height = C - H ;

    if (y < 0.01) {
        // Case 1.
        /*SSYDBL*/ NSLog(@"Case 1") ;
        visibleRect.origin.y = v - visibleRect.size.height ;
    }
    else {
        /*SSYDBL*/ NSLog(@"Case 2") ;
        // Case 2.
        visibleRect.origin.y += H ;
    }
    
    /*SSYDBL*/ NSLog(@"corr:     %@", NSStringFromRect(visibleRect)) ;
    /*SSYDBL*/ NSLog(@"------------------------") ;

//    /*SSYDBL*/ NSLog(@"visiRows: %@", NSStringFromRect(visibleRowsRect)) ;

    
    return visibleRect ;
}


- (void)scrollRowToTop:(NSInteger)row
       plusExtraPoints:(CGFloat)extraPoints {
    CGFloat y = 0 ;
	if ((row != NSNotFound) && (row >=0)) {
		CGFloat rowPitch = [self rowHeight] + [self intercellSpacing].height ;
        y = -[[self headerView] frame].size.height ;
        y += (row) * rowPitch ;
	}
    /*SSYDBL*/ CGFloat yB4 = y ;

    y += extraPoints ;
    
    [self scrollPoint:NSMakePoint(0, y)] ;
    // Above is o low-level method that scrolls Content, 1 of 2
    /*SSYDBL*/ NSLog(@"Scrolled to y = %f = %f + %f so that row %ld is at top", y, yB4, extraPoints, (long)row) ;
}

@end