#import <CoreImage/CoreImage.h>
#import "NSImage+SSYDarkMode.h"
#import "NSView+SSYDarkMode.h"

@implementation NSImage (SSYDarkMode)

- (void)drawInRect:(NSRect)frame
         operation:(NSCompositingOperation)operation
          fraction:(CGFloat)fraction
  invertIfDarkMode:(BOOL)doInvert
            inView:(NSView*)view {
    if (doInvert) {
        doInvert = view.isDarkMode_SSY;
    }

    if (!doInvert) {
        [self drawInRect:frame
                fromRect:NSMakeRect(0.0, 0.0, self.size.width, self.size.height)
               operation:operation
                fraction:1.0
          respectFlipped:YES
                   hints:nil];
    } else {
        /* We are going to create and apply two filters in succession.  Because
         the filters require separate input and output images, we pingpong
         between two images – starting with image1, applying filter1 to assign
         to image2, then applying filter2 to assign to image 1, which gets
         drawn. */
        CIImage* image1 = [[CIImage alloc] initWithData:[self TIFFRepresentation]];

        /* First Filter: Invert Colors.  Reference:
         https://stackoverflow.com/questions/2137744/draw-standard-nsimage-inverted-white-instead-of-black */
        CIFilter* filter1 = [CIFilter filterWithName:@"CIColorInvert"];
        [filter1 setDefaults];
        [filter1 setValue:image1 forKey:@"inputImage"];
        [image1 release];
        CIImage* image2 = [filter1 valueForKey:@"outputImage"];

        /* Second Filter: Scale.  Unlike NSImage whose -size is in points,
         CIImage -extent is in pixels.  So if this instance is created from
         reading a resource file and there is a @2x version available,
         image2.extent.size.width will be twice self.size.width.  The code
         below gives the scale we need, because we are going to draw the
         CIImage. */
        CIFilter* filter2 = [CIFilter filterWithName:@"CILanczosScaleTransform"];
        [filter2 setDefaults];
        CGFloat scale = frame.size.width / image2.extent.size.width;
        [filter2 setValue:@(scale) forKey:@"inputScale"];
        [filter2 setValue:image2 forKey:@"inputImage"];
        image1 = [filter2 valueForKey:@"outputImage"];

        [image1 drawAtPoint:frame.origin
                   fromRect:NSRectFromCGRect([image1 extent])
                  operation:operation
                   fraction:1.0];
    }
}

@end
