#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (SSYDarkMode)

/*!
 @brief    Replacement for NSImage draw:… methods which inverts colors if in
 Dark Mode

 @details  Cocoa takes care of Dark Mode for you by inverting luminance if you
 pass a NSImage with isTemplate = YES to a control such as a NSButton.  But
 if you draw such a NSImage yourself, in the -drawRect: method of a control or
 view, or the -drawWithFrame method of a cell, you need to do the inversion.
 This meethd does that for you.

 The "inversion" used is a different than that used by Cocoa for template
 images.  While this method applies a simple color inversion, Cocoa converts
 the opacity of the image to brightness.  While this works the same for
 most black and white template images, it is different for color in images.
 For example, in Dark Mode, this method converts blue to yellow.  I wonder if
 maybe dark blue to light blue would be better.  This is a work in progress.

 @param appaeranceView  An associated view, usually the view into which the
 receiver will be drawn, or the control view of the cell into which the
 receiver will be drawn.  This view is used only to get its effective
 appearance, to determine whether or not to draw in Dark Mode,
 */
- (void)drawInvertedIfDarkModeInRect:(NSRect)frame
                           operation:(NSCompositingOperation)operation
                            fraction:(CGFloat)fraction
                      appearanceView:(NSView*)view;

@end

NS_ASSUME_NONNULL_END
