#import <Cocoa/Cocoa.h>


@interface NSArray (Integers)

/*!
 @brief    Returns an array of NSNumbers whose -integerValues
 span a given range, each value being one more than the previous
 value.
*/
+ (NSArray*)arrayWithRange:(NSRange)range ;

@end

