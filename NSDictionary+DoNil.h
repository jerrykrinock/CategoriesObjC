#import <Cocoa/Cocoa.h>


@interface NSDictionary (DoNil)

/*!
 @brief    Compares two dictionaries or nil values for equality, doing a deep
 comparison of any subdictionaries
 
 @details  Use this instead of -isEqualToDictionary if it is possible that both
 objects are nil and/or if either contains subdictionaries which should also be
 traversed and checkd for equality.  Note that -[NSDictionary isEqualToDictionary]
 will not handle either of these cases as expected.
 @param    dic1  One of two dictionaries to be compared.  May be nil.
 @param    dic2  One of two dictionaries to be compared.  May be nil.
 @result   If neither argument is nil, the value which you'd get
 by sending -isEqualDeepToDictionary: to either of them.  If one parameter is nil
 and the parameter is not nil, NO.  If both arguments are nil, YES.
 */
+ (BOOL)isEqualDeepHandlesNilDic1:(NSDictionary*)dic1
							 Dic2:(NSDictionary*)dic2 ;

@end
