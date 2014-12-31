#import "NSImage+Transform.h"

@implementation NSImage (Transform)

- (NSImage*)imageRotatedByDegrees:(CGFloat)degrees {
	// Calculate the bounds for the rotated image
	// We do this by affine-transforming the bounds rectangle
	NSRect imageBounds = {NSZeroPoint, [self size]};
	NSBezierPath* boundsPath = [NSBezierPath bezierPathWithRect:imageBounds];
	NSAffineTransform* transform = [NSAffineTransform transform];
	[transform rotateByDegrees:degrees];
	[boundsPath transformUsingAffineTransform:transform];
	NSRect rotatedBounds = {NSZeroPoint, [boundsPath bounds].size};
	
	// Center the image within the rotated bounds
	imageBounds.origin.x = NSMidX(rotatedBounds) - (NSWidth(imageBounds) / 2);
	imageBounds.origin.y = NSMidY(rotatedBounds) - (NSHeight(imageBounds) / 2);
	
	// Start a new transform, to transform the image
	transform = [NSAffineTransform transform];
	
	// Move coordinate system to the center
	// (since we want to rotate around the center)
	[transform translateXBy:+(NSWidth(rotatedBounds) / 2)
						yBy:+(NSHeight(rotatedBounds) / 2)];
	// Do the rotation
	[transform rotateByDegrees:degrees];
	// Move coordinate system back to normal (bottom, left)
	[transform translateXBy:-(NSWidth(rotatedBounds) / 2)
						yBy:-(NSHeight(rotatedBounds) / 2)];
	
	// Draw the original image, rotated, into the new image
	// Note: This "drawing" is done off-screen.
    NSImage* rotatedImage = [NSImage imageWithSize:rotatedBounds.size
                                    flipped:NO
                             drawingHandler:^(NSRect dstRect) {
                                 [transform concat] ;
                                 [self drawInRect:imageBounds
                                         fromRect:NSZeroRect
                                        operation:NSCompositeCopy
                                         fraction:1.0] ;

                                 return YES ;
                             }] ;
	
	return rotatedImage;
}

- (NSImage*)darkenedImage {
    NSSize imageSize = [self size] ;
    NSRect rect = NSMakeRect(0.0, 0.0, imageSize.width, imageSize.height) ;
    NSImage* darkerImage = [NSImage imageWithSize:[self size]
                                           flipped:NO
                                    drawingHandler:^(NSRect dstRect) {
                                        [[NSColor colorWithCalibratedWhite:0.35 alpha:0.33] set] ;
                                        NSRectFillUsingOperation(rect, NSCompositeSourceOver) ;
                                        [self drawInRect:rect
                                                fromRect:rect
                                               operation:NSCompositeSourceOver
                                                fraction:0.75] ;
                                        
                                        return YES ;
                                    }] ;
    return darkerImage ;
}

@end

