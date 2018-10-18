#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (SSYDarkMode)

/*!
 @brief    Replacement for NSImage draw:… methods with option to invert
 colors if in Dark Mode

 @details  Cocoa takes care of Dark Mode for you by inverting luminance if you
 pass a NSImage with isTemplate = YES to a control such as a NSButton.  But
 if you draw such a NSImage yourself, in the -drawRect: method of a control or
 view, or the -drawWithFrame method of a cell, you may need to do the
 inversion yourself.

 The "inversion" used in this method is a different than that used by Cocoa for
 template images.  This method applies a simple color inversion.  But Cocoa
 maps opacity of the image to brightness.  While the two work the same for
 most black and white template images, it is different for colored images.
 For example, in Dark Mode, this method converts blue with opacity 1.0 to
 yellow, but Cocoa's method will convert it to white, due to the opacity.  I'm
 wondering if it might not be better to convert dark blue to light blue.
 The obvious, simple algorithm to do this (reflect the brightness about 0.5)
 seems like it gives results which are frequently too dark.  Deferred to
 future study, if I ever need this.

 @param inView  An associated view, usually the view into which the
 receiver will be drawn, or the control view of the cell into which the
 receiver will be drawn.  This view is only accessed to get its effective
 appearance, which is used to determine whether or not to draw in Dark Mode,
 If doInvert is NO, this parameter is ignored.
 */
- (void)drawInRect:(NSRect)frame
         operation:(NSCompositingOperation)operation
          fraction:(CGFloat)fraction
  invertIfDarkMode:(BOOL)doInvert
            inView:(NSView*)view;

@end

NS_ASSUME_NONNULL_END
