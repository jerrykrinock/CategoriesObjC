#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSView (SSYDarkMode)

/*!
 @brief    Returns indication of whether or not the receiver seems to be
 being viewed in macOS Dark Mode

 @details  The _SSY suffix is in case Apple implements this in a future
 version of Cocoa.
 */
 @property (readonly) BOOL isDarkMode_SSY;

@end

NS_ASSUME_NONNULL_END
