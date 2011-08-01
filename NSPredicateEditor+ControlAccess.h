#import <Cocoa/Cocoa.h>

/*!
 @brief    A category of NSPredicateEditor which adds
 methods for accessing the controls in the rows after
 they have been displayed.

 @details  The stock NSPredicateEditor gives access
 to the row templates but not to the actual rows that
 are created from the templates.
 
 Although this class does not invoke any Apple private
 methods, it does rely on a NSPredicateEditor's view
 structure which I reverse-engineered.&nbsp;  This
 view structure is not documented and therefore is,
 technically, subject to change.
 */
@interface NSPredicateEditor (ControlAccess)


/*!
 @brief    Removes all rows, including the root row.
*/
- (void)removeAllRows ;

/*!
 @brief    Returns the nth control from the left
 of a given class in a given row

 @details  A row usually has three controls, sometimes two.
 The left/first control is always a popup menu.&nbsp;  The
 middle/second control is either a popup menu or the static
 text "is".&nbsp;  The third/right control is either a
 popup menu or a text field.
 @param    class  The class of control which is desired,
 either NSPopUpButton or NSTextField
 @param    fromLeft  The index of the desired control of this
 class, starting with 0 for the left-hand control.
 @param    row  The row in which the desired control resides.
*/
- (NSControl*)controlOfClass:(Class)class
					fromLeft:(NSInteger)fromLeft
						inRow:(NSInteger)row ;

@end
