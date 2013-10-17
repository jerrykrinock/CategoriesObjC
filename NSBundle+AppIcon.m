#import "NSBundle+AppIcon.h"
#import "NSBundle+MainApp.h"

@implementation NSBundle (AppIcon)

- (NSString*)appIconPath {
	// Oddly, I can't find a constant for the bundle icon file.
	// Compare to kCFBundleNameKey, which is apparently "CFBundleName".
	NSString* iconFilename = [[NSBundle mainAppBundle] objectForInfoDictionaryKey:@"CFBundleIconFile"] ;
	// I do not use -pathForImageResource, in case the Resources also contains
	// an image file, for example a png, with the same name.  I want the .icns.
	NSString* iconBasename = [iconFilename stringByDeletingPathExtension] ;
	NSString* iconExtension = [iconFilename pathExtension] ;  // Should be "icns", but for some reason it's in Info.plist
	return [[NSBundle mainBundle] pathForResource:iconBasename
										   ofType:iconExtension] ;
}

- (NSImage*)appIcon {
	NSImage* appIcon = [[NSImage alloc] initWithContentsOfFile:[self appIconPath]] ;
	return [appIcon autorelease] ;
}

@end