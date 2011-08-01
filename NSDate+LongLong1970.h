#import <Cocoa/Cocoa.h>

@interface NSDate (LongLong1970)

/*!
 @brief    Returns the NSDate represented by a given value of
 microseconds since 1970
*/
+ (NSDate*)dateWithLongLongMicrosecondsSince1970:(NSNumber*)value ;

/*!
 @brief    Returns a number object whose long long value is the number
 of microseconds since 1970 represented by the receiver.
 */
- (NSNumber*)longLongMicrosecondsSince1970 ;

/*!
 @brief    Returns the number of microseconds since 1970 at the current
 time.
*/
+ (NSNumber*)longLongMicrosecondsSince1970 ;

@end

