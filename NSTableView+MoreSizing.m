#import "NSTableView+MoreSizing.h"

NSString* const constKeyMinWidthAnyColumn = @"minWidthAnyColumn" ;
NSString* const constKeyMinWidthFirstColumn = @"minWidthFirstColumn" ;


@implementation NSTableView (MoreSizing)


- (void)tryToResizeColumn:(NSTableColumn*)targetColumn
				  toWidth:(CGFloat)targetColumnRequestedWidth {
	// Make sure we start out with a table that is well formed
	[self sizeLastColumnToFit] ;

	NSArray* tableColumns = [self tableColumns] ;
	NSInteger nColumns = [tableColumns count] ;
	if (nColumns == 0) {
		return ;
	}
	
	NSInteger i ;
	NSTableColumn* tc ;	

	// Read minimums from user defaults
	// Actually, these are from the default defaults.  They are hidden preferences.
	// They are never written within in the app. They are only read here.
	CGFloat firstColumnMin = [[[NSUserDefaults standardUserDefaults] valueForKey:constKeyMinWidthFirstColumn] floatValue] ;
	CGFloat anyColumnMin = [[[NSUserDefaults standardUserDefaults] valueForKey:constKeyMinWidthAnyColumn] floatValue] ;
	// Note that if keys are not present in standardUserDefaults for the
	// above, firstColumnMin and anyColumnMin will default to 0.0.
	// However, we guard against such corrupt prefs:
	if (isnan(firstColumnMin) || (firstColumnMin < 0.0)) {
		NSLog(@"Warning 970-6144 Bad width %f", firstColumnMin) ;
		firstColumnMin = 80.0 ;
	}		
	if (isnan(anyColumnMin) || (anyColumnMin < 0.0)) {
		NSLog(@"Warning 654-0512 Bad width %f", anyColumnMin) ;
		anyColumnMin = 60.0 ;
	}		
	
	firstColumnMin = MAX(firstColumnMin, anyColumnMin) ;
	
	// Remember the initial widths
	NSMutableArray* originalWidths = [NSMutableArray array] ;
	CGFloat totalOriginalWidth = 0.0 ;
	CGFloat targetColumnOriginalWidth = 0.0 ;
	for (tc in tableColumns) {
		CGFloat width = [tc width] ;
		if (isnan(width) || (width < 0.0)) {
			NSLog(@"Warning 345-5610 Ignoring bad width %f", width) ;
			width = 80.0 ;
		}		
		[originalWidths addObject:[NSNumber numberWithFloat:width]] ;
		totalOriginalWidth += width ;
		if (tc == targetColumn) {
			targetColumnOriginalWidth = width ;
		}
	}
	
	// Do a trial run to find out how much delta is needed from other columns
	[self sizeToFit] ;
	CGFloat totalAvailableWidth = 0.0 ;
	for (tc in tableColumns) {
		totalAvailableWidth += [tc width] ;
	}

	CGFloat deltaAvailable = totalAvailableWidth - totalOriginalWidth ;
	CGFloat targetColumnDeltaRequested = targetColumnRequestedWidth - targetColumnOriginalWidth ;
	
	CGFloat deltaNeeded = deltaAvailable - targetColumnDeltaRequested ;
	
	// Set back to original widths
	i = 0 ;
	for (tc in tableColumns) {
		CGFloat width = [[originalWidths objectAtIndex:i] floatValue] ;
		[tc setWidth:width] ;
		i++ ;
	}
	
	// Negative deltaNeeded means that we must squeeze other columns
	// Positive deltaNeeded means that we must widen other columns
	
	// Add up the delta width available in the other columns
	NSMutableArray* deltasAvailable = [NSMutableArray array] ;
	CGFloat totalDeltaAvailable = 0.0 ;
	i = 0 ;
	for (tc in tableColumns) {
		CGFloat delta ;
		if (tc == targetColumn) {
			[deltasAvailable addObject:[NSNull null]] ;
		}
		else {
			if (i==0) {
				delta = firstColumnMin - [tc width] ;
			}
			else {
				delta = anyColumnMin - [tc width] ;
			}
			
			// We are only interested in negative deltas; columns that can get smaller
			delta = MIN(0.0, delta) ;
			[deltasAvailable addObject:[NSNumber numberWithFloat:delta]] ;
			totalDeltaAvailable += delta ;
		}
		
		i++ ;
	}
	// Negative totalDeltaAvailable is the width that other columns can be squeezed
	
	CGFloat newTargetWidth ;
	CGFloat delta ;
	if (deltaNeeded < totalDeltaAvailable) {
		// In this case, we cannot change targetColumn to targetColumnRequestedWidth

		// Example of how we might have gotten here:
		// Three columns, width currently 40, 50, 30
		// targetColumn is the middle column
		// targetColumnRequestedWidth is 140
		// firstColumnMin is 30
		// anyColumnMin is 20
		// Doing the trial run, target column will be set to 140
		// Original width is 40+50+30 = 120
		// First column will remain at 40.
		// Last column will be resized by eq'n 40+140+lastColWidth = 120
		// --> lastColWidth = -60
		// Total delta requested = -60 - 30 = -90
		// Total delta available = 30 - 40 + 20 - 30 = -20
		
		CGFloat otherColumnsWidth = 0 ;
		
		BOOL isFirstCol = YES ;
		for (tc in tableColumns) {
			CGFloat newWidth ;
			if (tc != targetColumn) {
				if (isFirstCol) {
					newWidth = firstColumnMin ;
					isFirstCol = NO ;
				}	
				else {
					newWidth = anyColumnMin ;
				}
				
				[tc setWidth:newWidth] ;
				otherColumnsWidth += newWidth ;
				i++ ;
			}
		}
		
		CGFloat widthLeftForTargetColumn = totalAvailableWidth - otherColumnsWidth ;
		if (isnan(widthLeftForTargetColumn) || (widthLeftForTargetColumn < 0.0)) {
			NSLog(@"Internal Error 460-5251 Bad width %f", widthLeftForTargetColumn) ;
			widthLeftForTargetColumn = 20.0 ;
		}		
		[targetColumn setWidth:widthLeftForTargetColumn] ;
		
		// Continuing our example,
		// newTargetWidth = 50 - - 20 = 70 ;
		// delta = -20 ;
	}
	else {
		// In this case, we can change targetColumn to targetColumnRequestedWidth

		// Example of how we might have gotten here:
		// Three columns, width currently 40, 50, 30
		// targetColumn is the middle column
		// targetColumnRequestedWidth is 60
		// firstColumnMin is 20
		// anyColumnMin is 10
		// Doing the trial run, target column will be set to 60
		// Original width is 40+50+30 = 120
		// First column will remain at 40.
		// Last column will be resized by eq'n 40+60+lastColWidth = 120
		// --> lastColWidth = 20
		// Total delta requested = 20 - 30 = -10
		// Total delta available = 20 - 40 + 10 - 50 = -60

		// Three columns, width currently 40, 50, 30
		// targetColumn is the middle column
		// targetColumnRequestedWidth is 300
		// firstColumnMin is 20
		// anyColumnMin is 10
		// Total delta requested = 20 - 30 = -10
		// Total delta available = 20 - 40 + 10 - 50 = -60
		
		
		newTargetWidth = targetColumnRequestedWidth ;
		delta = deltaNeeded ;
		// Continuing our example,
		// newTargetWidth = 60 ;
		// delta = -10 ;
		
		// In this loop, we only go thru the 2nd-last column
		for (i=0; i<(nColumns-1); i++) {
			tc = [tableColumns objectAtIndex:i] ;
			CGFloat newWidth ;
			if (tc == targetColumn) {
				newWidth = newTargetWidth ;				
			}
			else {
				CGFloat thisColumnFraction ;
				if (delta > 0) {
					// This column which must get bigger
					// Do it in proportion to current width relative to other non-target column widths
					thisColumnFraction = [tc width]/(totalOriginalWidth - targetColumnOriginalWidth) ;
				}
				else {
					// This column which must get smaller
					// Do it in proportion to its available delta relative to other non-target available deltas
					thisColumnFraction = [[deltasAvailable objectAtIndex:i] floatValue]/totalDeltaAvailable ;
				}
				CGFloat thisColumnDelta = delta * thisColumnFraction ;
				newWidth = [tc width] + thisColumnDelta ;
			}
			
			if (isnan(newWidth) || (newWidth < 0.0)) {
				NSLog(@"Internal Error 256-0594 Bad width %f", newWidth) ;
				newWidth = 20.0 ;
			}		
			[tc setWidth:newWidth] ;
		}
	}		
	
	// This will take care of the last column, and any roundoff errors:
	[self sizeLastColumnToFit] ;
}

- (void)proportionWidths:(CGFloat[])defaultWidths {
	[self sizeToFit] ;
	CGFloat availableTotal = 0.0 ;
	CGFloat defaultsTotal = 0.0 ;
	NSInteger i = 0 ;
	for (NSTableColumn* tableColumn in [self tableColumns]) {
		availableTotal += [tableColumn width] ;
		defaultsTotal += defaultWidths[i] ;
		i++ ;
	}
	
	CGFloat scaleFactor = availableTotal/defaultsTotal ;
	
	i = 0 ;
	for (NSTableColumn* tableColumn in [self tableColumns]) {
		CGFloat desiredWidth = defaultWidths[i] ;
		CGFloat scaledDesiredWidth = scaleFactor * desiredWidth ;
		[tableColumn setWidth:scaledDesiredWidth] ;
		i++ ;
	}
	
	[self sizeLastColumnToFit] ;
}

- (NSTableColumn*)tableColumnOfCurrentMouseLocationWithInset:(CGFloat)inset {
	NSPoint point = [[self window] convertScreenToBase:[NSEvent mouseLocation]] ;
	CGFloat mouseX = [self convertPoint:point
									fromView:nil].x ;

	CGFloat spacing = [self intercellSpacing].width ;
	
	CGFloat leftEdge = spacing ;
	// I assume that -tableColumns returns columns ordered from left to right,
	// even though documentation does not specify the order.
	NSTableColumn* column = nil ;
	for (column in [self tableColumns]) {
		CGFloat rightEdge = leftEdge + [column width] ;
		if (
			(mouseX - leftEdge > inset)
			&&
			(rightEdge - mouseX > inset)
			) {
			break ;
		}
		
		leftEdge = rightEdge + spacing ;
	}
	
	return column ;
}

@end