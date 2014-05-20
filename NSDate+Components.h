#import <Cocoa/Cocoa.h>


/*!
 @brief    A class for creating NSDate objects with arbitrary components,
 and for getting the components of NSDate objects.  Here, by
 "components", we mean the year, month, hours, etc., in the sense of
 NSDateComponents.
 
 @details  It seems to me that you really need these for dealing with
 recurring dates, for example scheduling events to occur every day at
 a given time.  I'm surprised that Apple doesn't provide this.
 I'm sure there's a reason, but I've never been able to stay awake
 long enough to read documents like Date and Time Programming Guide.
 I understand that one could get probably get a PhD degree in dates,
 but I just want something that works for 99% of the world.
*/
@interface NSDate (Components)

/*!
 @brief    Returns an NSDate equal to the current date
 and user's time zone, except certain component(s) which are
 replaced with values given in the parameter(s).

 @details  Pass NSNotFound as the parameter value for
 any component which you wish to assume its default value of
 the current date and user's time zone.&nbsp; Do not pass 0
 unless you really mean it, because when you later display
 the result, it will be offset to the user's time zone and
 daylight-savings-ness, which is probably not what you want.
*/
+ (NSDate*)dateWithYear:(NSInteger)year
				  month:(NSInteger)month
					day:(NSInteger)day
				   hour:(NSInteger)hour
				 minute:(NSInteger)minute
				 second:(NSInteger)second
		 timeZoneOffset:(NSInteger)timeZoneOffset ;

/*!
 @brief    Returns the year of the receiver as a string.
*/
- (NSString*)yearString ;

/*!
 @brief    Returns the month of the receiver as a string, padded with a leading
 zero if necessary to make two characters
 */
- (NSString*)monthString ;

/*!
 @brief    Returns the month of the receiver as a string, as one or two characters
 */
- (NSString*)monthStringWithoutLeadingZero ;

/*!
 @brief    Returns the day of the receiver as a string, padded with a leading
 zero if necessary to make two characters
 */
- (NSString*)dayString ;

/*!
 @brief    Returns the day of the receiver as a string, as one or two characters
 */
- (NSString*)dayStringWithoutLeadingZero ;

/*!
 @brief    Returns the hour of the receiver as a string.
 */
- (NSString*)hourString ;

/*!
 @brief    Returns the minute of the receiver as a string.
 */
- (NSString*)minuteString ;

/*!
 @brief    Returns the second of the receiver as a string.
 */
- (NSString*)secondString ;

/*!
 @brief    Returns the time zone offset of the receiver
as a string.
 */
- (NSString*)timeZoneOffsetString ;

/*!
 @brief    Returns the year of the receiver as an integer.
 */
- (NSInteger)year ;

/*!
 @brief    Returns the month of the receiver as an integer.
 */
- (NSInteger)month ;

/*!
 @brief    Returns the day of the receiver as an integer.
 */
- (NSInteger)day ;

/*!
 @brief    Returns the hour of the receiver as an integer.
 */
- (NSInteger)hour ;

/*!
 @brief    Returns the minute of the receiver as an integer.
 */
- (NSInteger)minute ;

/*!
 @brief    Returns the second of the receiver as an integer.
 */
- (NSInteger)second ;

@end
