#import <Cocoa/Cocoa.h>


/*!
 @ @brief    defined to be NSOrderedAscending

 @details  So I don't have to look at documentation every
 time I use -[NSDate compare:]
 */
#define NSDateIsEarlierThan NSOrderedAscending

/*!
 @ @brief    defined to be NSOrderedDescending

 @details  So I don't have to look at documentation every
 time I use -[NSDate compare:]
 */
#define NSDateIsLaterThan NSOrderedDescending

/*
 NSDate's instance methods such as -laterDate: may not give the
 sensible result when one of the dates is nil.  These class methods
 give sensible results in all cases. 
 */
@interface NSDate (SafeCompare)

/*!
 @brief    Returns the later of two dates, even if either is nil.

 @details  If either date is nil, returns the other date.&nbsp; If
 both dates are nil, returns nil.
 @result   date1, date2, or nil.
*/
+ (NSDate*)laterDate:(NSDate*)date1
				date:(NSDate*)date2 ;

+ (BOOL)isEqualHandlesNilDate1:(NSDate*)date1
                         date2:(NSDate*)date2
                     tolerance:(NSTimeInterval)tolerance ;


@end
