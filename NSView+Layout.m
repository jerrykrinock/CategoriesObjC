#import "NSView+Layout.h"
#import "NS(Attributed)String+Geometrics.h"

void SSMoveView(NSView* view, float dX, float dY) {
	NSRect frame = [view frame] ;
	frame.origin.x += dX ;
	frame.origin.y += dY ;
	[view setFrame:frame] ;
}

void SSResizeView(NSView* view, float dX, float dY) {
	NSRect frame = [view frame] ;
	frame.size.width += dX ;
	frame.size.height += dY ;
	[view setFrame:frame] ;
}	

void SSResizeViewMovingSubviews(NSView* view, float dXLeft, float dXRight, float dYTop, float dYBottom) {
	SSResizeView(view, dXLeft + dXRight, dYTop + dYBottom) ;
	
	NSArray* subviews = [view subviews] ;
	NSEnumerator* e ;
	NSView* subview ;
	
	// If we wanted to change the "left", move all existing subviews to the right
	if (dXLeft != 0.0) {
		e = [subviews objectEnumerator] ;
		while ((subview = [e nextObject])) {
			SSMoveView(subview, dXLeft, 0.0) ;
		}
	}
	
	// If we wanted to change the "bottom", move all existing subviews up
	if (dYBottom != 0.0) {
		e = [subviews objectEnumerator] ;
		while ((subview = [e nextObject])) {
			SSMoveView(subview, 0.0, dYBottom) ;
		}
	}
	[view display] ;
}

NSView* SSResizeWindowAndContent(NSWindow* window, float dXLeft, float dXRight, float dYTop, float dYBottom, BOOL moveSubviews) {
	NSView* view = [window contentView] ;
	if (moveSubviews) {
		SSResizeViewMovingSubviews(view, dXLeft, dXRight, dYTop, dYBottom) ;
	}
	else {
		SSResizeView(view, dXLeft + dXRight, dYTop + dYBottom) ; 
	}
	NSRect frame = [window frame] ;
	frame.size.width += (dXLeft + dXRight) ;
	frame.size.height += (dYTop + dYBottom) ;
	// Since window origin is at the bottom, and we want
	// the bottom to move instead of the top, we also
	// adjust the origin.y
	frame.origin.y -= (dYTop + dYBottom) ;
	// since screen y is measured from the top, we have to 
	// subtract instead of add
	[window setFrame:frame display:YES] ;
	
	return view ;  // because often this is handy
}

@implementation NSView (Layout) 

- (float)leftEdge {
	return [self frame].origin.x ;
}

- (float)rightEdge {
	return [self frame].origin.x + [self width] ;
}

- (float)centerX {
	return ([self frame].origin.x + [self width]/2) ;
}

- (void)setLeftEdge:(float)t {
	NSRect frame = [self frame] ;
	frame.origin.x = t ;
	[self setFrame:frame] ;
}

- (void)setRightEdge:(float)t {
	NSRect frame = [self frame] ;
	frame.origin.x = t - [self width] ;
	[self setFrame:frame] ;
}

- (void)setCenterX:(float)t {
	float center = [self centerX] ;
	float adjustment = t - center ;
	
	NSRect frame = [self frame] ;
	frame.origin.x += adjustment ;
	[self setFrame:frame] ;
}

- (float)bottom {
	return [self frame].origin.y ;
}

- (float)top {
	return [self frame].origin.y + [self height] ;
}

- (float)centerY {
	return ([self frame].origin.y + [self height]/2) ;
}

- (void)setBottom:(float)t {
	NSRect frame = [self frame] ;
	frame.origin.y = t ;
	[self setFrame:frame] ;
}

- (void)setTop:(float)t {
	NSRect frame = [self frame] ;
	frame.origin.y = t - [self height] ;
	[self setFrame:frame] ;
}

- (void)setCenterY:(float)t {
	float center = [self centerY] ;
	float adjustment = t - center ;
	
	NSRect frame = [self frame] ;
	frame.origin.y += adjustment ;
	[self setFrame:frame] ;
}

- (float)width {
	return [self frame].size.width ;
}

- (float)height {
	return [self frame].size.height ;
}

- (void)setWidth:(float)t {
	NSRect frame = [self frame] ;
	frame.size.width = t ;
	[self setFrame:frame] ;
}

- (void)setHeight:(float)t {
	NSRect frame = [self frame] ;
	frame.size.height = t ;
	[self setFrame:frame] ;
}

- (void)setSize:(NSSize)size {
	NSRect frame = [self frame] ;
	frame.size.width = size.width ;
	frame.size.height = size.height ;
	[self setFrame:frame] ;
}

- (void)deltaX:(float)dX
		deltaW:(float)dW {
	NSRect frame = [self frame] ;
	frame.origin.x += dX ;
	frame.size.width += dW ;
	[self setFrame:frame] ;
}

- (void)deltaY:(float)dY
		deltaH:(float)dH {
	NSRect frame = [self frame] ;
	frame.origin.y += dY ;
	frame.size.height += dH ;
	[self setFrame:frame] ;
}

- (void)deltaX:(float)dX {
	[self deltaX:dX
		  deltaW:0.0] ;
}

- (void)deltaY:(float)dY {
	[self deltaY:dY
		  deltaH:0.0] ;
}

- (void)deltaW:(float)dW {
	[self deltaX:0.0
		  deltaW:dW] ;
}

- (void)deltaH:(float)dH {
	[self deltaY:0.0
		  deltaH:dH] ;
}


- (void)sizeHeightToFitAllowShrinking:(BOOL)allowShrinking {
	float oldHeight = [self height] ;
	float width = [self width] ;
	float height ;
	if ([self isKindOfClass:[NSTextView class]]) {
		NSAttributedString* attributedString = [(NSTextView*)self textStorage] ;
		if (attributedString != nil) {
			height = [attributedString heightForWidth:width] ;
		}
		else {
			NSFont* font = [(NSTextView*)self font] ;
			// According to Douglas Davidson, http://www.cocoabuilder.com/archive/message/cocoa/2002/2/13/66379,
			// "The default font for text that has no font attribute set is 12-pt Helvetica."
			// So, we make that interpretation...
			if (font == nil) {
				font = [NSFont fontWithName:@"Helvetica"
									   size:12] ;
			}
			
			height = [[(NSTextView*)self string] heightForWidth:width
														   font:font] ;
		}
		NSRect frame = [self frame] ;
		frame.size.height = allowShrinking ? height : MAX(height, oldHeight) ;
		[self setFrame:frame] ;
	}
	else if ([self isKindOfClass:[NSTextField class]]) {
		gNSStringGeometricsTypesetterBehavior = NSTypesetterBehavior_10_2_WithCompatibility ;
		height = [[(NSTextField*)self stringValue] heightForWidth:width
															 font:[(NSTextView*)self font]] ;
		NSRect frame = [self frame] ;
		frame.size.height = allowShrinking ? height : MAX(height, oldHeight) ;
		[self setFrame:frame] ;
	}
	else {
		// Subclass should have set height to fit
	}

	// Clip if taller than screen
	float screenHeight = [[NSScreen mainScreen] frame].size.height ;
	if ([self height] > screenHeight) {
		NSRect frame = [self frame] ;
		frame.size.height = screenHeight ;
		[self setFrame:frame] ;
	}
}	

- (NSComparisonResult)compareLeftEdges:(NSView*)otherView {
	float myLeftEdge = [self leftEdge] ;
	float otherLeftEdge = [otherView leftEdge] ;
	if (myLeftEdge < otherLeftEdge) {
		return NSOrderedAscending ;
	}
	else if (myLeftEdge > otherLeftEdge) {
		return NSOrderedDescending ;
	}
	
	return NSOrderedSame ;
}

// The normal margin of "whitespace" that one leaves at the bottom of a window
#define BOTTOM_MARGIN 20.0

- (void)sizeHeightToFit {
	CGFloat minY = 0.0 ;
	for (NSView* subview in [self subviews]) {
		minY = MIN([subview frame].origin.y - BOTTOM_MARGIN, minY) ;
	}
	
	// Set height so that minHeight is the normal window edge margin of 20
	CGFloat deltaH = -minY ;
	NSRect frame = [self frame] ;
	frame.size.height += deltaH ;
	[self setFrame:frame] ; 
	
	// Todo: Set width similarly
}

@end