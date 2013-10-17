#import <Cocoa/Cocoa.h>

/*!
 @brief    Provides methods to access resources and user defaults of a main
 app, from a helper app or tool which is packaged into a main app
 
 @details  Prior to BookMacster 1.19.2, this category did a Method Replacement
 of +[NSBundle mainBundle] so that it returned the
 bundle of the main application when used in an auxiliary
 executable that is packaged in Contents/Helpers or Contents/SomeOther
 instead of Contents/MacOS of the main application's bundle.  I noticed I was
 having trouble with that.  Prefs were being written to, for example,
 com.companyName.Helper even though Helper was located inside of another
 bundle.  So, instead I removed that method replacement and instead added
 these methods.  It requires more code, and you need to be careful to use
 them whenever you want to access resources or user defaults of your main app,
 but it's less hacky.
*/
@interface NSBundle (MainApp)

+ (NSBundle*)mainAppBundle ;

@end
