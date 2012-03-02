#import <Cocoa/Cocoa.h>


@interface NSBundle (AppIcon)

/*!
 @brief    Returns the path to the application's icon file, derived
 from the .icns file specified by "CFBundleIconFile" in the application's
 Info.plist.
 */
- (NSString*)appIconPath ;

/*!
 @brief    Returns the image in the file specified by -appIconPath.
*/
- (NSImage*)appIcon ;

@end
