#import <Cocoa/Cocoa.h>


@interface NSImage (Transform)

/*!
 @brief    Rotates an image clockwise around its center by a given
 angle in degrees and returns the new image.
 
 @details  The width and height of the returned image are,
 respectively, the height and width of the receiver.
 
 I have not yet tested this with a non-square image.
 
 Consider another way to draw images rotated:
 
 CGContextRotateCTM(UIGraphicsGetCurrentContext(), M_PI / 2.0);
 [img drawAtPoint...];
 --
 David Duncan
 Apple DTS Animation and Printing
 */
- (NSImage*)imageRotatedByDegrees:(CGFloat)degrees ;

@end
