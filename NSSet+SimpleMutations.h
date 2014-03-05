#import <Cocoa/Cocoa.h>


@interface NSSet (SimpleMutations)

/*!
 @brief    Returns a new set, equal to the receiver except that
 any object which -isEqual to a given object has been removed
 @details  A complement to Apple's -setByAddingObject:
 @param    object  The object to be removed.&nbsp; It is
 ok if this object does not exist in the receiver.
 @result   An autoreleased copy of the receiver, with one
 or more objects possibly removed.
 */
- (NSSet*)setByRemovingObject:(id)object ;

/*!
 @brief    Returns a new set, equal to the receiver except that
 any object which -isEqual to an object in a given set has been removed
 @details  A complement to Apple's -setByAddingObjectsFromSet:
 @param    objects  The objects to be removed.&nbsp; It is
 ok if this set contains objects which do not exist in the receiver.
 @result   An autoreleased copy of the receiver, with one
 or more objects possibly removed.
 */
- (NSSet*)setByRemovingObjectsFromSet:(NSSet*)objects ;

/*
 @brief    If the receiver contains more objects than a given count, returns
 a clone of the receiver with objects arbitrarily removed so that its count is
 only the given count; otherwise, returns the receiver
 */
- (NSSet*)setByTruncatingToCount:(NSInteger)count ;

@end
