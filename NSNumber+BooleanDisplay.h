#import <Cocoa/Cocoa.h>


/*!
 @brief    Category for transforming a Boolean value to a human-readable word
 */
@interface NSNumber (BooleanDisplay)

/*!
 @brief    Returns the localized word "Yes" if the -boolValue of the
 receiver is YES and "No" if the -boolValue of the receiver is NO.
 */
- (NSString*)booleanDisplayName ;

@end
