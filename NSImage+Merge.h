#import <Cocoa/Cocoa.h>


@interface NSImage (Merge) 

/*!
 @brief    Returns an image constructed by tiling a given array
 of images side-by-side or top-to-bottom.

 @param    spacingX  Spacing which will be applied horizontally between
 images, and at the left and right borders.
 @param    spacingY  Spacing which will be applied vertitally between
 images, and at the bottom and top borders.
 @param    vertically  YES to tile the given images from top
 to bottom, starting with the first image in the array at the top.
 NO to tile the given images from left to right, starting with
 the first image in the array at the left.
*/
+ (NSImage*)imageByTilingImages:(NSArray*)images
					   spacingX:(CGFloat)spacingY
					   spacingY:(CGFloat)spacingY
					 vertically:(BOOL)vertically ;
	
- (NSImage*)imageBorderedWithInset:(CGFloat)inset ;

- (NSImage*)imageBorderedWithOutset:(CGFloat)outset ;

@end
