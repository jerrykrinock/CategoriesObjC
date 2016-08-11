#import <Foundation/Foundation.h>

@interface NSArray (SSYPathUtils)

/*!
 @brief     Returns an array of strings, interpreted as filesystem paths,
 which replicates the receiver except that any members (paths) which are
 descendants of other paths in the array have been removed.
 */
- (NSArray*)pathsByRemovingDescendants ;

@end
