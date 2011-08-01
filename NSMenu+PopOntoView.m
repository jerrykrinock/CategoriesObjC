#import "NSMenu+PopOntoView.h"

@implementation NSMenu (PopOntoView)

- (void)popOntoView:(NSView*)view
			atPoint:(NSPoint)origin
		  pullsDown:(BOOL)pullsDown {
    NSRect frame = [view frame] ;
    frame.origin = origin ;
	
    if (pullsDown) {
		[self insertItemWithTitle:@""
						   action:NULL
					keyEquivalent:@""
						  atIndex:0] ;
	}
	
    NSPopUpButtonCell *popUpButtonCell = [[NSPopUpButtonCell alloc] initTextCell:@""
																	   pullsDown:pullsDown] ;
    [popUpButtonCell setMenu:self] ;
    if (!pullsDown) {
		[popUpButtonCell selectItem:nil] ;
	}
    
	[popUpButtonCell performClickWithFrame:frame
									inView:view] ;
	[popUpButtonCell release] ;
}
@end
