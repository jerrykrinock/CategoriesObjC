#import <Cocoa/Cocoa.h>


/*!
 @brief    Including this category allows you to safely
 invoke -shortDescription on any object.
*/
@interface NSObject (MoreDescriptions)

/*!
 @brief    Subclasses can override to return a long
 description.&nbsp;  Default implementation returns 
 the normal -description.
*/
- (NSString*)longDescription ;

/*!
 @brief    Subclasses can override to return a short
 description.&nbsp;  Default implementation returns 
 the normal -description.
 */
- (NSString*)shortDescription ;

- (NSString*)deepNiceDescription ;

@end
