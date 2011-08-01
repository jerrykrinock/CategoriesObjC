#import "NSTableView+ContextMenu.h"
#import <objc/runtime.h>


@implementation NSTableView (ContextMenu)

+ (void)load {
	// Swap the implementations of -menuForEvent: and -replacement_menuForEvent.
	// When the -menuForEvent: message is sent to any NSTableView instance, -replacement_menuForEvent will
	// be invoked instead.  Conversely, -replacement_menuForEvent invokes -menuForEvent:.
        Method originalMethod = class_getInstanceMethod(self, @selector(menuForEvent:)) ;
        Method replacedMethod = class_getInstanceMethod(self, @selector(replacement_menuForEvent:)) ;
        method_exchangeImplementations(originalMethod, replacedMethod);
}

- (NSMenu*)replacement_menuForEvent:(NSEvent*)event {
	SEL selector = @selector(menuForTableColumnIndex:rowIndex:) ;
	
	NSMenu* menu ;
	
	if ([self respondsToSelector:selector]) {
		menu = nil ;
		
		NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil] ;
		int iCol = [self columnAtPoint:point];
		int iRow = [self rowAtPoint:point];
		
		if ((iCol >= 0) && (iRow >= 0)) {
			menu = [self menuForTableColumnIndex:iCol
										rowIndex:iRow];
		}
	}
	else {
        // Call the original sendEvent: method, whose implementation was exchanged with our own.
        // Note:  this ISN'T a recursive call, because this method should have been called through -sendEvent:.
        NSParameterAssert(_cmd == @selector(menuForEvent:));
        menu = [self replacement_menuForEvent:event];
	}
		
	return menu ;
}

@end
