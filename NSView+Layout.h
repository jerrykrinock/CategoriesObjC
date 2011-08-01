#import <Cocoa/Cocoa.h>

@interface NSView (Layout) 

	// Origin X
- (float)leftEdge ;
- (float)rightEdge ;
- (float)centerX ;
- (void)setLeftEdge:(float)t ;
- (void)setRightEdge:(float)t ;
- (void)setCenterX:(float)t ;

	// Origin Y
- (float)bottom ;
- (float)top ;
- (float)centerY ;
- (void)setBottom:(float)t ;
- (void)setTop:(float)t ;
- (void)setCenterY:(float)t ;

	// Size
- (float)width ;
- (float)height ;
- (void)setWidth:(float)t ;
- (void)setHeight:(float)t ;
- (void)setSize:(NSSize)size ;

	// Incrememental Changes
- (void)deltaX:(float)dX
		deltaW:(float)dW ;
- (void)deltaY:(float)dY
		deltaH:(float)dH ;
- (void)deltaX:(float)dX ;
- (void)deltaY:(float)dY ;
- (void)deltaW:(float)dW ;
- (void)deltaH:(float)dH ;


/*!
 @brief    Resizes the height of the receiver to fit its current content.
 
 @details  The default implementation works properly if the receiver is
 an NSTextField or NSTextView.&nbsp; For any other subclass, all it does
 is clip if the height is not taller than the screen, so subclasses
 may invoke super to get this function.&nbsp; Otherwise, it's a no-op, which
 is appropriate for subclasses that have a constant height,
 independent of their content, for example NSButton or NSPopUpButton.&nbsp;
 Todo: I should move the NSTextField and NSTextView code from
 this method into subclass methods, as I have done with NSTableView
 in SSLabelledList.m
 
 @param    allowShrinking  If YES, the method always resizes the
 receiver's height to fit the current content.&nbsp; If NO, and if the
 height required by the receiver's current content is smaller than
 the receiver's current height, the receiver's height is not resized.&nbsp; 
 This is used to avoid a changing height which could be annoying in many
 circumstances.
 */
- (void)sizeHeightToFitAllowShrinking:(BOOL)allowShrinking ;

/*!
 @brief    Compares the left edge of the receiver with the left
 edge of a other view.

 @param    otherView  
 @result   NSOrderedAscending if the other view's left edge is
 to the right of the receiver, etc.
*/
- (NSComparisonResult)compareLeftEdges:(NSView*)otherView ;

/*!
 @brief    Based on the "lowest" subview among the receiver's subview, 
 i.e. the one with the smallest frame.origin.y, sizes the receiver
 to fit it.

 @details  This method takes a completely different approach than the
 others in this class.  Indeed, it was written years later (201105).
*/
- (void)sizeHeightToFit ;


@end
