#import <Cocoa/Cocoa.h>


@interface NSNumber (SomeMore)

/*!
 @brief    Returns a new NSNumber with a boolValue equal
 to the opposite of the boolValue of the receiver.
*/
- (NSNumber*)negateBoolValue ;

/*!
 @brief    Returns a new NSNumber whose integer value is one
 more than that of the receiver.

 @result   An NSNumber made using +numberWithInt:
*/
- (NSNumber*)plus1 ;

@end
