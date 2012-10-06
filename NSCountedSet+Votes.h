#import <Cocoa/Cocoa.h>


@interface NSCountedSet (Votes)

#if 0
/*!
 @brief    Returns an array of the receiver's contents, ordered
 primarily by the count of each object, with higher counts
 first, and secondarily by comparing the objects with compare:.
 */
- (NSArray*)arrayOrderedByCount ;
#endif

/*!
 @brief    Returns the member of the receiver which has the
 highest count
 
 @details  Returns nil if there is more than one member with
 the highest count (a "tie").&nbsp;  Also returns nil if
 the receiver is empty.
*/
- (id)winner  ;

@end


@interface NSDictionary (Subdictionaries)

/*!
 @brief    Assuming that the receiver's objects are also
 dictionaries (subdictionaries), returns a counted set of all
 the different values for a given key in all the subdictionaries.
 
 @details  The count of each item in the returned set is equal
 to the number of subdictionaries which had an equal item as
 the object for the given key.&nbsp; If none of the
 subdictionaries have an object for the given key and no
 defaultObject is given, returns an empty set.
 
 @param    defaultObject  An object which will be added to the
 result, one for each subdictionary in the receiver which has
 no object for the given key, or nil if you do not want any object
 added for missing objects.
 */
- (NSCountedSet*)objectsInSubdictionariesForKey:(id)key
								  defaultObject:(id)defaultObject ;

@end