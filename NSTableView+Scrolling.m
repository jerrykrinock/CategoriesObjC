

@implementation NSTableView (Scrolling)

- (void)scrollRowToTop:(int)row {
	if ((row != NSNotFound) && (row >=0)) {
		float rowPitch = [self rowHeight] + [self intercellSpacing].height ;
		float y = row * rowPitch ;
		[self scrollPoint:NSMakePoint(0, y)] ;
	}
}

@end