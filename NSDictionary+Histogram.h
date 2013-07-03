#import <Cocoa/Cocoa.h>


@interface NSMutableDictionary (Histogram)

/*!
 @brief    Adds a given integer value of the object
 to the number object for a given key.

 @details  If the receiver does not have a value for the given key,
 or if the current object for the given key does not respond to the
 selector 'integerValue', then this current object is overwritten with an
 NSNumber object whose integer value is the given integer.
 
 If the values of your keys are never going to be negative, consider using
 NSCountedSet instead.
*/
- (void)addInteger:(NSInteger)value
             toKey:(NSString*)key ;

@end
