#import <Cocoa/Cocoa.h>

@interface NSRunningApplication (SSYHideReliably)

/*!
 @brief    Repeatedly tells an application to hide, for a specified interval
 
 @details  This is a wrapper around -[NSRunningApplication hide], which can
 be reliably sent immediately after the target app has been launched, and
 is useful for apps such as Google Chrome which seem to ignore the -g and -j
 arguments to /usr/bin/open.
 */
- (void)hideReliablyWithGuardInterval:(NSTimeInterval)guardInterval;

@end
