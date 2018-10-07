#import <Cocoa/Cocoa.h>


@interface NSProcessInfo (SSYMoreInfo) 

/*!
 @brief    Returns a human-readable dictionary of geeky information
 about the current process including arguments, environment, and
 information about the parent process; useful for debugging.
 */
- (NSDictionary*)geekyProcessInfo ;

/*!
 @brief

 @details  I'm not sure why this does not work.  It gives me a number which
 is ~1000 times bigger than the number given by ps -axww -o vsz -o rss, and
 128 times bigger than that of Activity Monitor.  Example:

 Activity Monitor "Memory" for this process = 38.5 MB
 `ps -axww -o vsz -o pid` prints 5039944 for this process
 This method returns 5,155,213,312 which looks to me like 5.1 GB.

 @param    error_p  Pointer which will, upon return, if an error
 occurred and said pointer is not NULL, point to an NSError
 describing said error.
 */
- (NSInteger)currentMemorySizeError_p:(NSError**)error_p;

@end
