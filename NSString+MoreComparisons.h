#import <Cocoa/Cocoa.h>


@interface NSString (MoreComparisons)

/*!
 @brief    Compares two string values for equality
 
 @details  Use this instead of -isEqualToString
 if it is possible that both strings are nil, because,
 unlike -isEqualToString, it will give the correct answer
 of YES.
 @param    string1  One of two strings to be compared.  May be nil.
 @param    string2  One of two strings to be compared.  May be nil.
 @result   If neither argument is nil, the value returned by sending
 -isEqualToString: to either of them.  If one argument is nil and the other
 is not nil, NO.  If both arguments are nil, YES.
 Otherwise, NO
 */
+ (BOOL)isEqualHandlesNilString1:(NSString*)string1
						 string2:(NSString*)string2 ;

@end
