#import <Cocoa/Cocoa.h>


@interface NSString (TimeIntervals)

/*!
 @brief    Returns a string such as "0.001 seconds", "0.020 seconds",
 "0.500 seconds", "30 seconds", "1 minutes", "2 hours",
 "66 hours", always rounding down to the nearest unit, unless interval
 is less than one second.

 @details  If, for example, interval is 62.918, returns "1 minutes".
 Units word is always plural.
 
 @param    longForm  If YES, you'll get "seconds", "minute", "hours".
 If NO, you'll get "secs", "mins", "hrs"
*/
+ (NSString*)stringWithUnitsForTimeInterval:(NSTimeInterval)interval
								   longForm:(BOOL)longForm ;

@end
