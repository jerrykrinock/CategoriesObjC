#import <Cocoa/Cocoa.h>


@interface NSTabView (Safe)

/*!
 @brief    A safer version of selectTabViewItemWithIdentifier: which
 performs no-op if the a tab view item with the given identifier does
 not exist in the receiver, instead of raising an exception.
*/
- (void)selectTabViewItemSafelyWithIdentifier:(NSString*)identifier ;

@end
