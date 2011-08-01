#import <Cocoa/Cocoa.h>


@interface NSCompoundPredicate (SSYMore)

/*!
 @brief    Returns an 'and' predicate whose andees are the key/value
 pairs in a given dictionary

 @detail  
 @param    dictionary  A dictionary whose keys are attributes of the
 object to which the predicate will ultimately be applied.
 @result  
*/
+ (NSPredicate*)andPredicateWithDictionary:(NSDictionary*)dictionary ;

@end
