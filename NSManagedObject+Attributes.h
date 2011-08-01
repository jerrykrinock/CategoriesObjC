#import <Cocoa/Cocoa.h>


@interface NSManagedObject (Attributes)

/*!
 @brief    Returns all attributes in the receiver's entity
 description, as an array of strings.
 */
- (NSSet*)allAttributes ;

/*!
 @brief    A dictionary containing all attribute keys of the
 receiver, and their values.
 
 @details  Does not give relationships.
 
 Regarding whether or not you want withNulls, Ben Trumbull of
 Apple gave this advice:
 
 cocoa-dev@lists.apple.com 20081219
 http://www.cocoabuilder.com/archive/cocoa/225972-copying-managed-objects-from-app-to-doc-mocontext.html
 
 Ben:  We tried omitting pairs with nil values, and stuff broke.  Like views
 didn't get updated because iterating over the values during setting with
 (nil = missing) meant nil values didn't get reset.  Like with undo or
 bindings.  Your setter here has that issue.  You may prefer that behavior,
 but we found it even more problematic than forcing clients to check for NSNull.
 
 Tip: If you want to copy both attributes and relationships, use
 -[NSKeyValueCodingProtocol dictionaryWithValuesForKeys:].
 
 @param    withNulls  If YES, attributes whose values are nil will
 be represented in the result as keys whose values are instances of
 NSNull.  If NO, such attributes will be omitted in the result.
 */
- (NSDictionary*)attributesDictionaryWithNulls:(BOOL)withNulls ;

/*!
 @brief    Sets the receiver's attributes from a dictionary
 
 @details  All keys in 'attributes' are attempted
 to be set using setValue:forKey:.  Thus, setValue:forUndefinedKey:
 will be invoked (and possibly an exception raised) if 'attributes'
 contains keys for which the receiver is not KVC compliant.
 
 attributes The dictionary of attributes to be set.
 */
- (void)setAttributes:(NSDictionary*)attributes ;

@end
