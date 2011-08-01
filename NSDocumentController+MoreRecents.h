#import <Cocoa/Cocoa.h>


@interface NSDocumentController (MoreRecents)

/*!
 @brief    Removes a document with a given URL from the receiver's
 list of Recent Documents

 @details  Due to lack of sufficient API from Apple, this method
 actually removes *all* recent documents, then replaces all except
 the one specified.  Seems to work OK, though.
*/
- (void)forgetRecentDocumentUrl:(NSURL*)url ;

/*!
 @brief    Returns display names of the current recent documents

 @result   An array with per-item correspondence to the array you
 get from -recentDocumentURLs.
*/
- (NSArray*)recentDocumentDisplayNames ;

/*!
 @brief    Returns a menu suitable to be the submenu of an "Open Recent"
 menu item for the application.

 @details  Pass in a target and action to specify an action message which
 will be sent when one of the items in the menu is clicked.  The sender
 parameter of the action will be one of the menu items, and this item's
 representedObject will be the file URL of a recent document.
 
 Typically, your target should respond to the action by opening the
 document specified by the given file URL.
*/
- (NSMenu*)recentDocumentsSubmenuWithTarget:(id)target
									 action:(SEL)action
								   fontSize:(CGFloat)fontSize  ;

@end
