#import <Cocoa/Cocoa.h>


@interface NSMenu (PopOntoView)

/*!
 @brief    Pops the receiver onto the screen at an arbitrary point

 @details  The receiver must be populated before invoking this method
 or nothing will happen.
 @param    view  The view whose frame will be used as a reference point
 to locate the menu
 @param    origin  The point in the given view at which the top left
 corner of the menu will be drawn
 @param    pullsDown  YES to pull down, NO to pop up
*/
- (void)popOntoView:(NSView*)view
			atPoint:(NSPoint)origin
		  pullsDown:(BOOL)pullsDown ;

@end
