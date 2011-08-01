#import <Cocoa/Cocoa.h>


@interface NSArray (Select1)

/*!
 @brief    Returns the single member object if the receiver's
 count is 1; otherwise returns NSNoSelectionMarker or
 NSMultipleValuesMarker as applicable.

 @details  This is useful in setting detail object values
 in a master-detail view, to show different placeholders,
 when the detail view's cell isSSYTokenFieldCell.
*/
- (id)select1 ;

@end

