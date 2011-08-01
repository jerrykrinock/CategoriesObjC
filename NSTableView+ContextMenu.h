#import <Cocoa/Cocoa.h>


/*!
 @brief  This class implements -menuForEvent: such that, if the (sub)class
 implements -menuForTableColumnIndex:rowIndex:, it will extract the relevant
 row and column from event and forward the message to 
 -menuForTableColumnIndex:rowIndex:.  Otherwise, it invokes Apple's
 method -menuForEvent:.
 
 @details  This is so that you don't have to re-implement the row
 and column extraction in every damned subclass of NSTableView.
 Uses technique given in http://developer.apple.com/samplecode/MethodReplacement/
*/
@interface NSTableView (ContextMenu)

@end

@interface NSTableView (ContextMenuImplementor)

/*!
 @brief    Subclasses or categories may implement to return a contextual
 menu for a given row and column.&nbsp;  If implemented, this method will be
 invoked by -menuForEvent:.
 
 @details  The idea is that implementing this method will be simpler than
 implementing -menuForEvent:.
 */
- (NSMenu*)menuForTableColumnIndex:(int)iCol
						  rowIndex:(int)iRow ;

@end

