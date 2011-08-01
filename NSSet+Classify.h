#import <Cocoa/Cocoa.h>


@interface NSSet (Classify)

/*!
 @brief    Copies each element of the receiver into a mutable set containing
 other elements of the same class and inserts the resulting mutable sets
 into a give mutable dictionary.

 @details  The keys in the dictionary are strings, class names obtained
 by using NSStringFromClass().&nbsp; The values are mutable sets.
 
 This method is designed so that it may be invoked in succession upon
 different sets with the same dictionary argument.&nbsp; In
 the end, the dictionary will contain one key/value pair for each
 class of object found in all of the receiver arrays.
 
 Note that because the output dictionary contains sets, duplicate
 objects will appear only once per set.
 
 @param    dic  A mutable dictionary to which mutable sets of 
 classified objects will be added.
*/
- (void)classifyByClassIntoSetsInDictionary:(NSMutableDictionary*)dic ;

@end
