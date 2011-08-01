#import <Cocoa/Cocoa.h>


@interface NSArray (SortByKey) 

/*!
 @brief    Returns an array consisting of a single sort descriptor, set
 to sort ascending with -localizedCaseInsensitiveCompare: by a given key.
 
 @details  The objects in the array to which this sort descriptor
 is applied must be strings.  NSNumber does not respond to 
 -localizedCaseInsensitiveCompare:.
*/
+ (NSArray*)sortDescriptorsForStringValueForKey:(NSString*)key ;

/*!
 @brief    Returns a copy of the receiver, sorted by the value of
 a given key using -localizedCaseInsensitiveCompare:
 
*/
- (NSArray*)arraySortedByStringValueForKey:(NSString*)key ;


/*!
 @brief    Returns a copy of the receiver, sorted by the value of
 a given key using -compare:
 
 @param    details  If keyPath is nil, defaults to @"description"
 */
- (NSArray*)arraySortedByKeyPath:(NSString*)keyPath ;


@end


@interface NSMutableArray (SortByKey) 

/*!
 @brief    Sorts the array by a given key, using -localizedCaseInsensitiveCompare

 @details  Note that due to -localizedCaseInsensitiveCompare, this
 is appropriate for strings but not for numbers.
*/
- (void)sortByStringValueForKey:(NSString*)key ;

@end
