#import <Cocoa/Cocoa.h>

/*!
 @brief    Replaces method +[NSBundle mainBundle] so that it returns the
 bundle of the main application when used in an auxiliary
 executable that is packaged in Contents/Helpers or Contents/SomeOther
 instead of Contents/MacOS of the main application's bundle.
 
 @details  Requires Mac OS X 10.5 or later.&nbsp;  Uses Method Replacement.
*/
@interface NSBundle (MainApp)
@end
