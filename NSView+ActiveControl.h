#import <Cocoa/Cocoa.h>


@interface NSView (ActiveControl) 

/*!
 @brief    Returns YES if the receiver's window is the mainWindow,
 and is the keyWindow, and if the receiver is the first responder
 of its window.

 @details  For example, use this to determine if the receiver
 should be highlighted or just secondary.
*/
- (BOOL)isTheActiveControl ;

@end
