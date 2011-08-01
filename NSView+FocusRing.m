
@implementation NSView (FocusRing)

// Invoke the following metod during -awakeFromNib
- (void)patchPreLeopardFocusRingDrawingForScrolling {
	if (NSAppKitVersionNumber < 900) {
		// In Tiger and Panther, the remnants of the focus ring will stay
		// on screen as the view is scrolled.  The following patch fixes that:
		NSView* clipView = self;
		while((clipView = [clipView superview]) != nil) {
			if([clipView isKindOfClass:[NSClipView class]])
				break ; 
		}
		
		[(NSClipView*)clipView setCopiesOnScroll:NO] ;
	}
}

- (void)drawFocusRing {
	[self lockFocus] ; // Needed in case we were not invoked from within drawRect:
	[[NSColor keyboardFocusIndicatorColor] set];
	NSRect rect = [self visibleRect] ;
	[NSGraphicsContext saveGraphicsState];
	NSSetFocusRingStyle(NSFocusRingOnly);
	NSFrameRect(rect);
	[NSGraphicsContext restoreGraphicsState];
	// The above code is from:
	// http://www.cocoabuilder.com/archive/message/cocoa/2003/4/7/88648
	// The remainder of that message applies to pre-Leopard only
	// and is implemented in this class' -patchPreLeopardFocusRingDrawingForScrolling.
	[self unlockFocus] ; // Balance lockFocus
}

@end
