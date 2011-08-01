//
#import <Cocoa/Cocoa.h>


@interface NSArray (Indexing)

/*!
 @brief    Iterates through an array whose objects each conform to the
 SSYIndexee protocol, starting with a given index, and sets the index
 attribute of each object to equal its index in the receiver.

 @param    index  The index of the first object whose index attribute
 may be modified.
*/
- (void)fixIndexesContiguousStartingAtIndex:(NSInteger)index ;

@end

