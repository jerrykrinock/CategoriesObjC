@implementation NSView (FocusRing)

- (void)drawFocusRing {
	[[NSColor keyboardFocusIndicatorColor] set];
	NSRect rect = [self visibleRect] ;
	[NSGraphicsContext saveGraphicsState];
	NSSetFocusRingStyle(NSFocusRingOnly);
	NSFrameRect(rect);
	[NSGraphicsContext restoreGraphicsState];
	// The above code is from:
	// http://www.cocoabuilder.com/archive/message/cocoa/2003/4/7/88648
	// The remainder of that message applies to pre-Leopard only.
}

@end
