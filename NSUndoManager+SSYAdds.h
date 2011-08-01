#import <Cocoa/Cocoa.h>


/*!
 @brief    This is my attempt to create an undo manager which
 whose undo action will be the first undo action set in an undo
 grouping.

 @details  http://www.cocoabuilder.com/archive/message/cocoa/2005/8/22/144791  
 
 I AM NOW USING SSYDooDooUndoManager INSTEAD OF THIS.  IT IS SIMILAR.
*/
@interface NSUndoManager (SSYAdds)

- (void)logUndoStack ;

@end
