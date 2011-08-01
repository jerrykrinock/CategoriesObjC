#import <Cocoa/Cocoa.h>

@interface NSView (FocusRing)

- (void)patchPreLeopardFocusRingDrawingForScrolling ;

- (void)drawFocusRing ;
// Although the above method invokes -lockFocus, and thus will work if
// invoked while not within -drawRect, it is recommended to invoke this
// method from within -drawRect, to avoid the possibility of a 
// later invocation of -drawRect by Cocoa for some other purpose, which it
// does frequently, will wipe out the focus ring that has just been drawn.
// This can happen even before the focus ring has a chance to show!
	
@end
