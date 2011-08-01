#import <Cocoa/Cocoa.h>


@interface NSOperationQueue (Depends)

/*!
 @brief    Adds to the receiver's operation queue a new operation
 which will not begin until all operations currently in the queue
 have completed.

 @details  Does this by setting the new operation to be dependent
 upon all existing operations before adding to the queue.
*/
- (void)addAtEndOperation:(NSOperation*)operation ;

@end
