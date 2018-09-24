#import "NSBundle+MainApp.h"
#import <objc/runtime.h>

static NSBundle* mainAppBundle = nil ;

@implementation NSBundle (MainApp)

+ (NSBundle*)mainAppBundle {
    @synchronized(self) {
        if (!mainAppBundle) {
            /* See if path is a symbolic link, because if this process
             was launched by a symbolic link, starting in macOS 10.14,
             this path will be the symbolic link's path!!

             (Similarly, if this process is a bare executable, and was
             launched via symbolic link, [[NSBundle mainBundle] bundlePath]
             will return the parent of the symbolic link, which is useless
             for our purpose here.)  I have not  tested what
             [[NSBundle mainBundle] bundlePath] returns if this process is in a
             bundle but launched via a symbolic link. */
            NSString* path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
            NSString* symlinkDestin = [[NSFileManager defaultManager] destinationOfSymbolicLinkAtPath:path
                                                                                                error:NULL];
            if (symlinkDestin) {
                path = symlinkDestin;
            }

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
