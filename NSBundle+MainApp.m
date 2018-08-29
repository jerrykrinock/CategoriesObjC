#import "NSBundle+MainApp.h"
#import <objc/runtime.h>

static NSBundle* mainAppBundle = nil ;

@implementation NSBundle (MainApp)

+ (NSBundle*)mainAppBundle {
    @synchronized(self) {
        if (!mainAppBundle) {
            NSBundle* innermostBundle = [NSBundle mainBundle] ;
            NSString* path = [innermostBundle bundlePath] ;
            while (path.length > 4) {
                if ([path hasSuffix:@".app"]) {
#if !__has_feature(objc_arc)
                    [mainAppBundle release];
#endif
                    mainAppBundle = [NSBundle bundleWithPath:path];
#if !__has_feature(objc_arc)
                    [mainAppBundle retain];
#endif
                }

                path = [path stringByDeletingLastPathComponent];
            }
        }
    }
    
	return mainAppBundle ;
}

@end
