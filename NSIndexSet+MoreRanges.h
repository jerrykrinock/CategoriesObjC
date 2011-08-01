#import <Cocoa/Cocoa.h>


@interface NSIndexSet (MoreRanges)

/*!
 @brief    Returns an index set of indexes that are in the
 receiver and also are in a given range.
*/
- (NSIndexSet*)indexesInRange:(NSRange)range ;

@end
