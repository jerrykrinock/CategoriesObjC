#import <Cocoa/Cocoa.h>


@interface NSMenu (Ancestry)

/*!
 @brief    Returns the menu item to which the receiver is a submenu.
 
 @details  It does this by finding the menu item in the receiver's
 supermenu's itemArray whose submenu is the receiver itself.
 If the receiver has no supermenu, returns nil.
 */
- (NSMenuItem*)supermenuItem ;

/*!
 @brief    Returns the tag of the menu item in the receiver's supermenu's
 itemArray whose submenu is the receiver.
 
 @details  If the receiver has no supermenu, returns NSNotFound.&nbsp; 
 You can use this like the "tag" of a menu item, although it is not really.
 */
- (NSInteger)supertag ;

@end
