#import "NSImage+Merge.h"
#import "NSArray+Reversing.h"

@implementation NSImage (Merge)

+ (NSImage*)imageByTilingImages:(NSArray*)images
					   spacingX:(CGFloat)spacingX
					   spacingY:(CGFloat)spacingY
					 vertically:(BOOL)vertically {
	CGFloat mergedWidth = 0.0 ;
	CGFloat mergedHeight = 0.0 ;
	if (vertically) {
		images = [images arrayByReversingOrder] ;
	}
	for (NSImage* image in images) {
		NSSize size = [image size] ;
		if (vertically) {
			mergedWidth = MAX(mergedWidth, size.width) ;
			mergedHeight += size.height ;
			mergedHeight += spacingY ;
		}
		else {
			mergedWidth += size.width ;
			mergedWidth += spacingX ;
			mergedHeight = MAX(mergedHeight, size.height) ;
		}
	}
	// Add the outer margins for the single-image dimension
	// (The multi-image dimension has already had it added in the loop)
	if (vertically) {
		// Add left and right margins
		mergedWidth += 2 * spacingX ;
	}
	else {
		// Add top and bottom margins
		mergedHeight += 2 * spacingY ;
	}
	NSSize mergedSize = NSMakeSize(mergedWidth, mergedHeight) ;
	
    NSImage* mergedImage = [NSImage imageWithSize:mergedSize
                           flipped:NO
                    drawingHandler:^(NSRect dstRect) {
                        CGFloat x = spacingX ;
                        CGFloat y = spacingY ;
                        for (NSImage* image in images) {
                            [image drawAtPoint:NSMakePoint(x, y)
                                      fromRect:NSZeroRect
                                     operation:NSCompositeSourceOver
                                      fraction:1.0] ;
                            if (vertically) {
                                y += [image size].height ;
                                y += spacingY ;
                            }
                            else {
                                x += [image size].width ;
                                x += spacingX ;
                            }
                        }
                        
                        return YES ;
                    }] ;
	
	return mergedImage ;
}

- (NSImage*)imageBorderedWithInset:(CGFloat)inset {
    NSImage* image ;
    image = [NSImage imageWithSize:[self size]
                           flipped:NO
                    drawingHandler:^(NSRect dstRect) {
                        [self drawAtPoint:NSZeroPoint
                                 fromRect:NSZeroRect
                                operation:NSCompositeCopy
                                 fraction:1.0] ;
                        
                        NSBezierPath* path = [NSBezierPath bezierPath] ;
                        
                        //[[NSColor colorWithCalibratedWhite:0.0 alpha:0.7] set] ;
                        [[NSColor grayColor] setStroke] ;
                        [path setLineWidth:inset] ;
                        
                        // Start at left
                        [path moveToPoint:NSMakePoint(inset/2, inset/2)] ;
                        
                        // Move to the right
                        [path relativeLineToPoint:NSMakePoint(self.size.width - (2.5)*inset, 0)] ;
                        
                        // Move up
                        [path relativeLineToPoint:NSMakePoint(0, self.size.height - inset)] ;
                        
                        // Move left
                        [path relativeLineToPoint:NSMakePoint(-self.size.width + (2.5)*inset, 0)] ;
                        
                        // Finish
                        [path closePath] ;
                        [path stroke] ;
                        
                        return YES ;
                    }] ;
    
    return image ;
}

- (NSImage*)imageBorderedWithOutset:(CGFloat)outset {
	NSSize newSize = NSMakeSize([self size].width + 2*outset, [self size].height + 2*outset) ;
    NSImage* image ;
    image = [NSImage imageWithSize:newSize
                           flipped:NO
                    drawingHandler:^(NSRect dstRect) {
                        [self drawAtPoint:NSMakePoint(outset, outset)
                                 fromRect:NSZeroRect
                                operation:NSCompositeCopy
                                 fraction:1.0] ;
                        
                        NSBezierPath* path = [NSBezierPath bezierPath] ;
                        
                        //[[NSColor colorWithCalibratedWhite:0.0 alpha:0.7] set] ;
                        [[NSColor grayColor] setStroke] ;
                        [path setLineWidth:2.0] ;
                        
                        // Start at left
                        [path moveToPoint:NSMakePoint(1.0, 1.0)] ;
                        
                        // Move to the right
                        [path relativeLineToPoint:NSMakePoint(newSize.width - 2.0, 0)] ;
                        
                        // Move up
                        [path relativeLineToPoint:NSMakePoint(0, newSize.height - 2.0)] ;
                        
                        // Move left
                        [path relativeLineToPoint:NSMakePoint(-newSize.width + 2.0, 0)] ;
                        
                        // Finish
                        [path closePath] ;
                        [path stroke] ;
                        
                        return YES ;
                    }] ;
    return image ;
}

@end