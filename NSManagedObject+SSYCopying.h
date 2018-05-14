#import <CoreData/CoreData.h>

@interface NSManagedObject (SSYCopying)

/*!
 @brief    Returns a "copy" of the receiver, inserted into a given managed
 object context, having all of the same attributes as the receiver, but ignoring
 all of the receiver's relationships
 */
- (NSManagedObject*)shallowCopyInManagedObjectContext:(NSManagedObjectContext*)targetMoc ;

/*!
 @brief    Returns a "copy" of the receiver, inserted into a given managed
 object context, having all of the same attributes as the receiver, copying
 relationships by inserting additional objects as required to fulfill all
 relationships, except specified relationship(s)
 
 @param    doNotEnterRelationships  Those of the receiver's
 relationships which will be skipped; in other words, the copy will be
 "shallow" with respect to these relationships.  This is to avoid infinite loops
 wherein related objects would copy one another infinitely.  Typically, you
 pass a set containing one object, the name of the relationship to the
 receiver's "parent" in your object graph.  This parameter may be nil.
 
 Sending this message to an object which has a loop in their object graph would,
 I suspect, result in an infinite loop.
 */
- (NSManagedObject*)deepCopyInManagedObjectContext:(NSManagedObjectContext*)targetMoc
                           doNotEnterRelationships:(NSSet*)relationships ;

/*!
 @brief    Returns the result of
 -deepCopyInManagedObjectContext:doNotEnterRelationships: obtained by passing
 a set of relationships specified by a set of given relationship names.
 */
- (NSManagedObject*)deepCopyInManagedObjectContext:(NSManagedObjectContext*)targetMoc
                       doNotEnterRelationshipNames:(NSSet*)relationshipNames ;

/*!
 @brief    Invokes deepCopyInManagedObjectContext:doNotEnterRelationshipNames:
 with a single *do not enter* relationship name
 */
- (NSManagedObject*)deepCopyInManagedObjectContext:(NSManagedObjectContext*)targetMoc
                        doNotEnterRelationshipName:(NSString*)relationshipName ;

/*!
 @brief    Invokes deepCopyInManagedObjectContext:doNotEnterRelationshipNames:
 with zero *do not enter* relationship names
 @details  Be careful with this one that you won't create an infinite loop.
 */
- (NSManagedObject*)deepCopyInManagedObjectContext:(NSManagedObjectContext*)targetMoc ;

/*!
 @brief    Gives all attributes
 @details  This method is for debugging.
 */
- (NSString*)deepDescriptionIgnoringRelationshipWithName:(NSString*)ignoredName ;


@end
