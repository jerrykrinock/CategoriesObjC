#import "NSBundle+MainApp.h"
#import <objc/runtime.h>


// Cache for efficiency.  Bundle should not move while running!
static NSBundle* mainAppBundle = nil ;
// Used static storage because cannot add ivar in a category

@implementation NSBundle (MainApp)

+ (void)load {
	// Swap the implementations of +mainBundle and +replacement_mainBundle.
	// When the +mainBundle message is sent to the NSBundle class object,
	// +replacement_mainBundle will be invoked instead.  Conversely,
	// +replacement_mainBundle will invoke +mainBundle.
	Method originalMethod = class_getClassMethod(self, @selector(mainBundle)) ;
	Method replacedMethod = class_getClassMethod(self, @selector(replacement_mainBundle)) ;
	method_exchangeImplementations(originalMethod, replacedMethod) ;
}

+ (NSBundle*)replacement_mainBundle {
	NSBundle* myMainAppBundle ;
 	@synchronized(self) {
		myMainAppBundle = mainAppBundle ;
	}
	
	if (!myMainAppBundle) {
		// The following looks like we're calling ourselves into
		// an infinite loop, but because of the swap, we're
		// actually invoking the original +mainBundle
		NSBundle* bundle = [NSBundle replacement_mainBundle] ;
 		NSString* mainAppBundlePath = [bundle bundlePath] ;
		while (YES) {
			if ([[[mainAppBundlePath lastPathComponent] pathExtension] isEqual:@"app"]) {
				break ;
			}
			if ([mainAppBundlePath length] < 2) {
                // mainAppBundlePath is probably "/"
				NSLog(@"Warning 263-1857  Program apparently not in a .app") ;
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