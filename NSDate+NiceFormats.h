#import <Cocoa/Cocoa.h>


@interface NSDate (NiceFormats) 

/*!
 @brief    Returns a string representation of the receiver formatted
 with medium date style and short time style
*/
- (NSString*)medDateShortTimeString ;

/*!
 @brief    Returns a string representation of the receiver formatted
 as "YYYY-MM-DD HH:mm:ss"
 */
- (NSString*)geekDateTimeString ;

/*!
 @brief    Returns a string representation of the receiver formatted
 as @"YYYY-MM-DD HH:mm:ss.SSS", where SSS is milliseconds.
 */
- (NSString*)geekDateTimeStringMilli ;

/*!
 @brief    Returns a string representation of the receiver formatted
 as @"HH:mm:ss".
 */
- (NSString*)hourMinuteSecond ;

/*!
 @brief    Returns a string representation of the receiver formatted
 as YYYYMMDDHHmmss±HHmm
 */
- (NSString*)compactDateTimeString ;

/*!
 @brief    Returns the current date as formatted by
 -medDateShortTimeString.
*/
+ (NSString*)currentDateFormattedConcisely ;

@end
