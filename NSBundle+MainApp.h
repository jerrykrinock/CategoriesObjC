#import <Cocoa/Cocoa.h>

@interface NSBundle (MainApp)

/*!
 @brief    Returns the bundle of the outermost parent application (directory
 name ending in ".app") containing the currently-running main bundle

 @details  Typically you use this in a helper app so you can get resources
 in the bundle of a main (parent) app.

 The answer is cached for efficiency.  This assumes that the bundle will not
 move while running.  This is a common assumption in macOS.
 */
+ (NSBundle*)mainAppBundle ;

@end
