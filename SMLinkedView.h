#import <Cocoa/Cocoa.h>
#import "SMViewLinking.h"


@interface SMLinkedView : NSView <SMViewLinking> {
	NSMutableArray *linkedViews;
	SMViewLinkingLinkedResizingMask linkedResizingMask;
	NSSize linkedMinSize, linkedMaxSize;
}
@end
