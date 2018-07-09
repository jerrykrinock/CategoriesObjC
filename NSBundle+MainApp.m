#import "NSBundle+MainApp.h"
#import <objc/runtime.h>


// Cache for efficiency.  We assume that the bundle will not move while running.
static NSBundle* mainAppBundle = nil ;

@implementation NSBundle (MainApp)

+ (NSBundle*)mainAppBundle {
    //NSLog(@"MAB %@", SSYDebugCaller());
    return [NSBundle bundleWithPath:@"/Users/jk/Library/Developer/Xcode/DerivedData/BkmkMgrs-erjagcrpeurpyadfanfvztysloib/Build/Products/Debug/BookMacster.app"];
	NSBundle* myMainAppBundle ;
 	@synchronized(self) {
		myMainAppBundle = mainAppBundle ;
	}
	
	if (!myMainAppBundle) {
		NSBundle* bundle = [NSBundle mainBundle] ;
 		NSString* mainAppBundlePath = [bundle bundlePath] ;
		while (YES) {
			if ([[[mainAppBundlePath lastPathComponent] pathExtension] isEqual:@"app"]) {
				break ;
			}
			if ([mainAppBundlePath length] < 2) {
                // mainAppBundlePath is probably "/"
				mainAppBundlePath = nil ;
				break ;
			}
			
			mainAppBundlePath = [mainAppBundlePath stringByDeletingLastPathComponent] ;
 		}
		myMainAppBundle = [NSBundle bundleWithPath:mainAppBundlePath] ;

		@synchronized(self) {
 			mainAppBundle = myMainAppBundle ;
		}
	}
	
	return myMainAppBundle ;
}

@end
