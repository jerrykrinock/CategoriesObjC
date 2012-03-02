#import <Cocoa/Cocoa.h>


@interface NSPopUpButton (Populating)

- (void)populateTitles:(NSArray*)titles
				target:(id)target
				action:(SEL)action ;

// Because this category is also used in Bookdog,
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= 1050)		

/*!
 @brief    Sets tag of first item in receiver's itemArray
to 0, tag of 2nd item to 1, etc.
*/
- (void)tagItemsAsPositioned ;

#endif

@end

