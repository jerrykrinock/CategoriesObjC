#import <Cocoa/Cocoa.h>


@interface NSDictionary (DoNil)

/*!
 @brief    Compares two dictionaries for equality
 
 @details  Use this instead of -isEqualToDictionary if it is possible that both
 objects are nil, because, unlike -isEqualToDictionary, it will give the expected answer
 of YES.
 @param    dic1  One of two dictionaries to be compared.  May be nil.
 @param    dic2  One of two dictionaries to be compared.  May be nil.
 @result   If neither argument is nil, the value returned by sending
 -isEqualToDictionary: to either of them.  If one argument is nil and the other
 is not nil, NO.  If both arguments are nil, YES.  Otherwise, NO.
 */
+ (BOOL)isEqualHandlesNilDic1:(NSDictionary*)dic1
						 Dic2:(NSDictionary*)dic2 ;

@end
