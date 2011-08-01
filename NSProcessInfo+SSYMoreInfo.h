#import <Cocoa/Cocoa.h>


@interface NSProcessInfo (SSYMoreInfo) 

/*!
 @brief    Returns a human-readable dictionary of geeky information
 about the current process including arguments, environment, and
 information about the parent process; useful for debugging.
 */
- (NSDictionary*)geekyProcessInfo ;


@end
