#import <Cocoa/Cocoa.h>

/*!
 @brief    A nonreversible transformer which reduces a collection
 to a BOOL stating whether or not the collection is empty.
 
 @details  My first attempt at this was to bind to ...aCollection.count
 and then use SSYTransformShortToBool, but that raised an exception:
 [<_NSFaultingMutableSet 0x24bfd60> addObserver:forKeyPath:options:context:] is not supported. Key path: count
 My guess is that this error occured because SSYTransformCollectionNotEmpty is
 reversible, and it was trying to setCount:
 
 So, now I use this nonreversible transformer instead.
 */
@interface SSYTransformCollectionNotEmpty : NSValueTransformer {}
@end

#if 0
NOT USED AT THIS TIME
/*!
 @brief    A nonreversible transformer which reduces a collection
 to a BOOL stating whether or not the collection is empty.
*/
@interface SSYTransformCollectionIsEmpty : NSValueTransformer {}
@end
#endif