#import <Cocoa/Cocoa.h>


@interface NSMenuItem (Font)

/*!
 @brief    Sets the text font size and color of the receiver

 @details  This method operates by reading the receiver's title and
 then setting its attributed title.  Therefore, you must set the
 title first, and *then* send this message, and *then* do not make
 any further changes to either title or attributedTitle.
 @param    color  Set to nil for default font color (black)
 @param    size   Set to 0.0 for default font size
*/
- (void)setFontColor:(NSColor*)color
				size:(CGFloat)size  ;

@end
