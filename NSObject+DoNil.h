#import <Cocoa/Cocoa.h>


@interface NSObject (DoNil)

/*!
 @brief    Compares two object values for equality

 @details  Use this instead of -isEqual if it is possible that both
 objects are nil, because, unlike -isEqual, it will give the expected answer
 of YES.
 @param    object1  One of two objects to be compared.  May be nil.
 @param    object2  One of two objects to be compared.  May be nil.
 @result   If neither argument is nil, the value returned by sending
 -isEqual: to either of them.  If one argument is nil and the other
 is not nil, NO.  If both arguments are nil, YES.  Otherwise, NO.
 */
+ (BOOL)isEqualHandlesNilObject1:(id)object1
						 object2:(id)object2 ;

/*!
 @brief    Returns the given object, unless it is nil, then returns
 a short string explaining the nil.
 
 @details  Handy for avoiding exceptions and crashes
*/
+ (id)fillIfNil:(id)object ;
	
/*!
 @brief    Returns whether or not a given value is different than the
 existing value for a given key path

 @details  Uses isEqualHandlesNilObject1:object2:, so therefore it
 correctly gives expected answer if either existing or given value are
 nil.
 */
- (BOOL)isDifferentValue:(id)value
			  forKeyPath:(id)keyPath ;

// Because this category is also used in Bookdog,
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= 1050)		

/*!
 @brief    Iterates -isDifferentValue:forKey: over a dictionary of
 given values for given key paths s and returns YES if one or more of them
 indicate a difference.
 
 @param    newValues  A dictionary whose keys are key paths which the receiver
 responds to, and whose values are the "proposed" given values for their
 key.
 */
- (BOOL)isAnyDifferentValueInDictionary:(NSDictionary*)newValues ;

#endif

@end
