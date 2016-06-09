#import "NSView+Layout.h"
#import "NS(Attributed)String+Geometrics.h"

void SSMoveView(NSView* view, CGFloat dX, CGFloat dY) ;
void SSResizeView(NSView* view, CGFloat dX, CGFloat dY) ;
void SSResizeViewMovingSubviews(NSView* view, CGFloat dXLeft, CGFloat dXRight, CGFloat dYTop, CGFloat dYBottom) ;
NSView* SSResizeWindowAndContent(NSWindow* window, CGFloat dXLeft, CGFloat dXRight, CGFloat dYTop, CGFloat dYBottom, BOOL moveSubviews) ;

void SSMoveView(NSView* view, CGFloat dX, CGFloat dY) {
	NSRect frame = [view frame] ;
	frame.origin.x += dX ;
	frame.origin.y += dY ;
	[view setFrame:frame] ;
}

void SSResizeView(NSView* view, CGFloat dX, CGFloat dY) {
	NSRect frame = [view frame] ;
	frame.size.width += dX ;
	frame.size.height += dY ;
	[view setFrame:frame] ;
}	

void SSResizeViewMovingSubviews(NSView* view, CGFloat dXLeft, CGFloat dXRight, CGFloat dYTop, CGFloat dYBottom) {
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

NSView* SSResizeWindowAndContent(NSWindow* window, CGFloat dXLeft, CGFloat dXRight, CGFloat dYTop, CGFloat dYBottom, BOOL moveSubviews) {
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

- (CGFloat)leftEdge {
	return [self frame].origin.x ;
}

- (CGFloat)rightEdge {
	return [self frame].origin.x + [self width] ;
}

- (CGFloat)centerX {
	return ([self frame].origin.x + [self width]/2) ;
}

- (void)setLeftEdge:(CGFloat)t {
	NSRect frame = [self frame] ;
	frame.origin.x = t ;
	[self setFrame:frame] ;
}

- (void)setRightEdge:(CGFloat)t {
	NSRect frame = [self frame] ;
	frame.origin.x = t - [self width] ;
	[self setFrame:frame] ;
}

- (void)setCenterX:(CGFloat)t {
	CGFloat center = [self centerX] ;
	CGFloat adjustment = t - center ;
	
	NSRect frame = [self frame] ;
	frame.origin.x += adjustment ;
	[self setFrame:frame] ;
}

- (CGFloat)bottom {
	return [self frame].origin.y ;
}

- (CGFloat)top {
	return [self frame].origin.y + [self height] ;
}

- (CGFloat)centerY {
	return ([self frame].origin.y + [self height]/2) ;
}

- (void)setBottom:(CGFloat)t {
	NSRect frame = [self frame] ;
	frame.origin.y = t ;
	[self setFrame:frame] ;
}

- (void)setTop:(CGFloat)t {
	NSRect frame = [self frame] ;
	frame.origin.y = t - [self height] ;
	[self setFrame:frame] ;
}

- (void)setCenterY:(CGFloat)t {
	CGFloat center = [self centerY] ;
	CGFloat adjustment = t - center ;
	
	NSRect frame = [self frame] ;
	frame.origin.y += adjustment ;
	[self setFrame:frame] ;
}

- (CGFloat)width {
	return [self frame].size.width ;
}

- (CGFloat)height {
	return [self frame].size.height ;
}

- (void)setWidth:(CGFloat)t {
	NSRect frame = [self frame] ;
	frame.size.width = t ;
	[self setFrame:frame] ;
}

- (void)setHeight:(CGFloat)t {
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

- (void)deltaX:(CGFloat)dX
		deltaW:(CGFloat)dW {
	NSRect frame = [self frame] ;
	frame.origin.x += dX ;
	frame.size.width += dW ;
	[self setFrame:frame] ;
}

- (void)deltaY:(CGFloat)dY
		deltaH:(CGFloat)dH {
	NSRect frame = [self frame] ;
	frame.origin.y += dY ;
	frame.size.height += dH ;
	[self setFrame:frame] ;
}

- (void)deltaX:(CGFloat)dX {
	[self deltaX:dX
		  deltaW:0.0] ;
}

- (void)deltaY:(CGFloat)dY {
	[self deltaY:dY
		  deltaH:0.0] ;
}

- (void)deltaW:(CGFloat)dW {
	[self deltaX:0.0
		  deltaW:dW] ;
}

- (void)deltaH:(CGFloat)dH {
	[self deltaY:0.0
		  deltaH:dH] ;
}


- (void)sizeHeightToFitAllowShrinking:(BOOL)allowShrinking {
	CGFloat oldHeight = [self height] ;
	CGFloat width = [self width] ;
	CGFloat height = 0.0 ;
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
	}
	else if ([self isKindOfClass:[NSTextField class]]) {
		gNSStringGeometricsTypesetterBehavior = NSTypesetterBehavior_10_2_WithCompatibility ;
		height = [[(NSTextField*)self stringValue] heightForWidth:width
															 font:[(NSTextView*)self font]] ;
	}
    else if ([self isKindOfClass:[NSScrollView class]] && [[(NSScrollView*)self documentView] isKindOfClass:[NSTextView class]]) {
        gNSStringGeometricsTypesetterBehavior = NSTypesetterBehavior_10_2_WithCompatibility ;
        NSSize textSize = [NSScrollView contentSizeForFrameSize:[self frame].size
                                        horizontalScrollerClass:[NSScroller class]
                                          verticalScrollerClass:[NSScroller class]
                                                     borderType:NSNoBorder
                                                    controlSize:NSRegularControlSize
                                                  scrollerStyle:NSScrollerStyleOverlay] ;

        NSTextView* textView = (NSTextView*)[(NSScrollView*)self documentView] ;
        height = [textView.string heightForWidth:(textSize.width)
                                            font:textView.font] ;
        
        /* I found that OS X 10.11.3 or 10.11.4 is a little too anxious to
         automatically add the vertical scroller.  That is, it will add the
         vertical scroller when it is not quite necessary, and the resulting
         reduction in width will, in a self-fulfilling prophecy, make the
         scroller necessary.  To avoid that from happening, we manually set
         hasVerticalScroller to NO when *we* know we don't need it, and to
         YES when we know we need it.
         
         I also switch off the elasticity when the scroller is not necessary,
         so that it behaves like a regular text view, as opposed to one embedded
         in a scroll view, which would bounce up and down if the user happens to
         swipe on it.
         
         Scroll view should only get smaller, not bigger. */
        if (height > oldHeight) {
            ((NSScrollView*)self).hasVerticalScroller = YES ;
            ((NSScrollView*)self).verticalScrollElasticity = NSScrollElasticityAutomatic ;
            height = oldHeight ;
        }
        else {
            ((NSScrollView*)self).hasVerticalScroller = NO ;
            ((NSScrollView*)self).verticalScrollElasticity = NSScrollElasticityNone ;
        }
        
    }
    else {
		// Subclass should have set height to fit
	}
    
    if (height > 0.0) {
        NSRect frame = [self frame] ;
        
        CGFloat frameHeight = height ;
        if (!allowShrinking) {
            if (frameHeight < oldHeight) {
                frameHeight = oldHeight ;
            }
        }
        frame.size.height = frameHeight ;

        [self setFrame:frame] ;
    }

#if 0
	// At one point, I clipped if this was taller than the screen.  However, that
	// screwed up downstream clipping in SSYAlert, where the buttons needed to be
	// placed on the screen.  So, the following code is OUT
	CGFloat screenHeight = [[NSScreen mainScreen] frame].size.height ;
	if ([self height] > screenHeight) {
		NSRect frame = [self frame] ;
		frame.size.height = screenHeight ;
		[self setFrame:frame] ;
	}
#endif
}	

- (NSComparisonResult)compareLeftEdges:(NSView*)otherView {
	CGFloat myLeftEdge = [self leftEdge] ;
	CGFloat otherLeftEdge = [otherView leftEdge] ;
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
        CGFloat aMin = [subview frame].origin.y - BOTTOM_MARGIN ;
        if (minY > aMin) {
            minY = aMin ;
        }
	}
	
	// Set height so that minHeight is the normal window edge margin of 20
	CGFloat deltaH = -minY ;
	NSRect frame = [self frame] ;
	frame.size.height += deltaH ;
	[self setFrame:frame] ; 
	
	// Todo: Set width similarly
}

@end
