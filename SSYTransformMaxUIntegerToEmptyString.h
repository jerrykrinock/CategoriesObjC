#import <Cocoa/Cocoa.h>

/*!
 @brief    A nonreversible transformer which converts a number
 object created from an unsigned integer to the natural string
 representation of the integer.

 @details  If the -unsignedIntValue of the input is NSUIntegerMax,
 returns an empty string.
*/
@interface SSYTransformMaxUIntegerToEmptyString : NSValueTransformer {}
@end
