#import <Cocoa/Cocoa.h>


@interface NSPredicate (SSYMore)

/*!
 @brief    Returns a predicate which is satisfied if the values 
 of the subject object, for a given dictionary of keys, each equal
 the values in the dictionary
*/
+ (NSPredicate*)andPredicateWithDictionary:(NSDictionary*)dictionary ;

/*!
 @brief    Returns a predicate which is satisfied if the value of a
 subject object for a given key equals one of the values in a given set
*/
+ (NSPredicate*)orPredicateWithKeyPath:(NSString*)keyPath
								values:(NSSet*)values ;
@end
