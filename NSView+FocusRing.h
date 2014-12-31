#import <Cocoa/Cocoa.h>

@interface NSView (FocusRing)

- (void)patchPreLeopardFocusRingDrawingForScrolling ;

- (void)drawFocusRing ;
	
@end
