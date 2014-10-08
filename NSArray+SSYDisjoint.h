#import <Foundation/Foundation.h>

/*!
 @brief    Methods which allow you to put objects beyond the end of
 an array
 
 @details  Use this when you need to populate an array out of order.
 */
@interface NSMutableArray (SSYDisjoint)

/*!
 @brief    Similar to -replaceObject:atIndex:, except that index may
 exceed the size of the array
 
 @details  If index exceeds the size of an array, the skipped objects
 are filled in with a special SSYDisjoiningPlaceholder object.
 */
- (void)putObject:(id)object
          atIndex:(NSUInteger)index ;

/*!
 @brief    Replaces the object at a given index with a SSYDisjoiningPlaceholder
 objects and then, starting at the end of the array, removes all contiguous
 SSYDisjoiningPlaceholder objects.
 
 @details  This method is kind of the opposite of -putObject:atIndex:.  It
 "removes" the object at a given index, then removes the placeholders, if
 any, which were "supporting" it.
*/
- (void)cleanObjectAtIndex:(NSInteger)index ;

@end

#if 0
// TEST CODE

NSMutableArray* a = [[NSMutableArray alloc] initWithObjects:
                     @"zero", @"one", @"two", @"three", nil] ;
[a putObject:@"six"
     atIndex:6] ;
NSLog(@"a = %@", a) ;
[a cleanObjectAtIndex:2] ;
NSLog(@"a = %@", a) ;
[a cleanObjectAtIndex:6] ;
NSLog(@"a = %@", a) ;

#endif