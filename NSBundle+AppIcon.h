#import <Cocoa/Cocoa.h>


@interface NSBundle (AppIcon)

/*!
 @brief    Returns an image of the application's icon, derived the from
 the .icns file specified by "CFBundleIconFile" in the application's
 Info.plist.
*/
- (NSImage*)appIcon ;

@end
