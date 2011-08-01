#import <Cocoa/Cocoa.h>


@interface NSArray (SimpleMutations)

/*!
 @brief    Returns a new array, equal to the receiver
 except with a all objects that -isEqual a given object removed

 @details  A complement to Apple's -arrayByAddingObject
 @param    object  The object to be removed.&nbsp; It is
 ok if this object does not exist in the array.
 @result   An autoreleased copy of the receiver, with one
 or more objects possibly removed.
*/
- (NSArray*)arrayByRemovingObject:(id)object ;

/*!
 @brief    Returns a new array, equal to the receiver
 except with a single object at a given index removed.
 
 @details  Does not check to see if given index exists.
 Will raise an exception if it does not.
 @param    index  The index of the object to be removed.&nbsp;
 This index must exist in the receiver.
 @result   An autoreleased copy of the receiver, with one
 element possibly removed.
 */
- (NSArray*)arrayByRemovingObjectAtIndex:(NSUInteger)index ;

/*!
 @brief    Returns a replica of the receiver, with a given object
 inserted at a given index, unles object is nil, then returns
 the receiver
*/
- (NSArray*)arrayByInsertingObject:(id)object
						   atIndex:(NSInteger)index ;

/*!
 @brief    If a given object is not -isEqual: to an existing
 object in the receiver, returns a new array with the
 given object added; otherwise, returns the receiver.
 
 @details  Another complement to Apple's -arrayByAddingObject.
 Yes, you can get similar behavior by converting the array
 to a mutable set and then converting back, but unlike that
 technique, this method will preserve the existing order.
 @result   An autoreleased copy of the receiver, with one
 element added, or the receiver itself.
 */
- (NSArray*)arrayByAddingUniqueObject:(id)object ;

/*!
 @brief    Same idea as arrayByAddingUniqueObject: except
 adds multiple such objects.
 
 @details  Does not check for uniqueness among the objects
 of the given array -- If 'array' contains two equal
 objects that are not in the receiver, result will contain
 these two objects.&nbsp;  If 'array' is nil, returns
 the receiver.
 @param    array  The array of objects to be added if
 they are not already in the array, or nil. */
- (NSArray*)arrayByAddingUniqueObjectsFromArray:(NSArray*)array ;

/*!
 @brief    Returns a new array, equal to the receiver
 except containing only the first of any group of objects
 that that elicit YES from a given isEqualSelector.
 
 @details  If your isEqualSelector is -isEqual:, use
 -arrayByRemovingEqualObjects instead.
 */
- (NSArray*)arrayByRemovingObjectsEqualPerSelector:(SEL)isEqualSelector ;

/*!
 @brief    Returns a new array, equal to the receiver
 except containing only the first of any group of objects
 that are -isEqual:.

 @details  If you don't care about preserving the order,
 you can remove duplicates in an array by cascade invocation
 of -[NSSet setWithArray:] and -[NSSet allObjects].&nbsp; 
 This method is for when you need to preserve the order.
*/
- (NSArray*)arrayByRemovingEqualObjects ;

/*!
 @brief    Returns a new array whose members are all objects 
 in the receiver that are also in another given collection.
*/
- (NSArray*)arrayIntersectingCollection:(NSObject <NSFastEnumeration> *)collection ;

/*!
 @brief    Returns a new array whose members are all objects 
 in the receiver that are not in another given collection.
 */
- (NSArray*)arrayMinusCollection:(NSObject <NSFastEnumeration> *)collection ;

/*!
 @brief    Given arrays of existing and sets of new additions and
 deletions, mutates the existing sets to reflect the new additions and
 deletions.
 
 @details  First, checks newAdditions and newDeletions for common
 members which cancel each other out, and if any such are found, removes
 them from both sets.  Then, for each remaining new addition, if
 a deletion of the same object exists, removes it ("cancels it out"),
 and if not, adds it to the existing additions.  Finally, for each
 remaining new deletion, if a addition of the same object exists,
 removes it ("cancels it out"), and if not, adds it to the existing
 deletions. */
+ (void)mutateAdditions:(NSMutableArray*)additions
			  deletions:(NSMutableArray*)deletions
		   newAdditions:(NSMutableSet*)newAdditions
		   newDeletions:(NSMutableSet*)newDeletions ;


@end

#if 0
TEST CODE FOR +[NSArray mutateAdditions::::]

NSMutableArray* additions = [NSMutableArray arrayWithObjects: @"A1", @"A2", @"A3", @"A4", @"A5", nil] ;
NSMutableArray* deletions = [NSMutableArray arrayWithObjects: @"D1", @"D2", @"D3", @"D4", @"D5", nil] ;
NSMutableSet* newAdditions = [NSMutableSet setWithObjects: @"A3", @"A1", @"D5", @"D1", nil] ;
NSMutableSet* newDeletions = [NSMutableSet setWithObjects: @"A1", @"A5", @"D3", @"A2", nil] ;
// Expected results:
// A1  No change since it was added and deleted
// A2  Should not appear since it is a new deletion
// A3  Should be added again and now appear twice
// A4  No change
// A5  Should not appear since it is a new deletion
// D1  Should not appear since it is a new addition
// D2  No change
// D3  Should be added again and now appear twice
// D4  No change
// D5  Should not appear since it is a new addition

[NSArray mutateAdditions:additions
			   deletions:deletions
			newAdditions:newAdditions
			newDeletions:newDeletions] ;
BOOL test ;
test = [additions isEqualToArray:[NSArray arrayWithObjects:@"A1", @"A3", @"A4", @"A3", nil]] ;
NSAssert(
		 test,
		 @"Error 1 in +[NSArray mutateAdditions::::]"
		 ) ;
test = [deletions isEqualToArray:[NSArray arrayWithObjects:@"D2", @"D3", @"D4", @"D3", nil]] ;
NSAssert(
		 test,
		 @"Error 2 in +[NSArray mutateAdditions::::]"
		 ) ;
NSLog(@"+[NSArray mutateAdditions::::] passed test.") ;
exit(0) ;

#endif