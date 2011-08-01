#import <Cocoa/Cocoa.h>


#if 0
@interface NSMutableDictionary (Histogram)

/*!
 @brief    Increments the integer value of the object
 for a given key in the receiver by 1.

 @details  If the receiver does not have a value for the given key,
 or if the current object for the given key does not respond to the
 selector 'count', then this current object is overwritten with an
 NSNumber object whose integer value is 1.
*/
- (void)incrementIntegerValueForKey:(NSString*)key ;

@end
#endif