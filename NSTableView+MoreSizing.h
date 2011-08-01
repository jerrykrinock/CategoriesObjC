#import <Cocoa/Cocoa.h>


extern NSString* const constKeyMinWidthAnyColumn ;
extern NSString* const constKeyMinWidthFirstColumn ;

@interface NSTableView (MoreSizing)

/*!
 @brief    Attempts to set a given column to a given width,
 subject to optional minimum-width constraints on other columns
 which are in user defaults.
 
 @details  The minimum column for other columns are values for
 these keys in -[NSUserDefaults standardUserDefaults]:
 *  For the first column: constKeyMinWidthFirstColumn
 *  For any column: constKeyMinWidthAnyColumn

 If these two keys are not present in user defaults, a default
 value of 0.0 is assumed.
 
 Uses -sizeLastColumnToFit first, to make sure that the table
 is "well formed", and then once more at the end, to make the
 final adjustment.
 */
- (void)tryToResizeColumn:(NSTableColumn*)targetColumn
				  toWidth:(CGFloat)requestedWidthForTargetColumn ;

/*!
 @brief    Sets the widths of all columns in the receiver
 in proportion to the numbers in a given C array, without
 changing the (overall) width of the receiver itself

 @details  The size of the array must be equal to the
 number of columns in the receiver.  Test before sending
 with an assertion like this:
 NSAssert1(NUMBER_OF_COLUMNS == [self numberOfColumns], @"nCols=%d", [self numberOfColumns]) ;

 @param    defaultWidths  
*/
- (void)proportionWidths:(CGFloat[])defaultWidths ;

/*!
 @brief    If the current mouse location is inside any of the
 receiver's table columns, with an inset, returns that table
 column; otherwise, returns nil.
 
 @param    inset  The distance by which the mouse must be to
 the right of a column's left edge, or to the left of its
 right edge, for it to be considered "inside".

*/
- (NSTableColumn*)tableColumnOfCurrentMouseLocationWithInset:(CGFloat)inset ;

@end
