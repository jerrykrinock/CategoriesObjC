#import "NSWindow+Sizing.h"

//@implementation NSButton (Reframing)
//
//- (void)setWidthToFitTitlePlusTotalMargins:(float)totalMargins {
//	if (title != nil) {
//		NSRect frame = [self frame] ;
//		float titleWidth = [[self title] widthForHeight:frame.size.height
//													 font:[self font]] ;
//		frame.size.width = titleWidth + totalMargins ;
//		[self setFrame:frame] ;
//	}
//}
//
//@end


@implementation NSWindow (Sizing) 

- (void)setFrameToFitContentViewThenDisplay:(BOOL)display {
	NSRect frameW = NSMakeRect(0,0,255,255) ;
	NSRect frameC = [self contentRectForFrameRect:frameW] ;
	CGFloat titleToolBarHeight = frameW.size.height - frameC.size.height ;
	
	frameC = [[self contentView] frame] ;
	frameW = [self frame] ;
	
	CGFloat newHeight = frameC.size.height + titleToolBarHeight ;
	CGFloat dY = newHeight - frameW.size.height ;
	
	frameW.size.width = frameC.size.width ;
	frameW.size.height = newHeight ;
	// Since window origin is at the bottom, and we want
	// the bottom to move instead of the top, we also
	// adjust the origin.y.  However, since screen y is 
	// measured from the top, we must subtract instead of add
	frameW.origin.y -= dY ;
	
	[self setFrame:frameW display:display] ;
}

#define BOTTOM_MARGIN 20.0

- (void)setFrameToFitContentThenDisplay:(BOOL)display {
	NSView* contentView =[self contentView] ;
	CGFloat minY = 0.0 ;
	for (NSView* subview in [[self contentView] subviews]) {
		minY = MIN([subview frame].origin.y - BOTTOM_MARGIN, minY) ;
	}
	
	// Set height so that minHeight is the normal window edge margin of 20
	CGFloat deltaH = -minY ;
	NSRect frame = [contentView frame] ;
	frame.size.height += deltaH ;
	[contentView setFrame:frame] ; 
	
	// Todo: Set width similarly
	
	[self setFrameToFitContentViewThenDisplay:display] ;
}


#if 0
- (CGFloat)toolbarHeight {
    CGFloat toolbarHeight = 0.0;
	
    NSToolbar* toolbar = [self toolbar];
	
    if(toolbar && [toolbar isVisible]) {
        NSRect windowFrame = [NSWindow contentRectForFrameRect:[self frame]
													 styleMask:[self styleMask]] ;
        toolbarHeight = NSHeight(windowFrame) - NSHeight([[self contentView] frame]) ;
    }

	return toolbarHeight ;
}
#endif

- (CGFloat)tootlebarHeight {
	// Calculate the height of the title bar + height of the toolbar
	// by considering a hypothetical window size and running
	// -contentRectForFrameRect: in reverse
	NSRect frameW = NSMakeRect(0,0,255,255) ;
	NSRect frameC = [self contentRectForFrameRect:frameW] ;
	CGFloat tootlebarHeight = (frameW.size.height-frameC.size.height) ;

	return tootlebarHeight ;
}

@end