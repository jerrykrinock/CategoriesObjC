#import <Cocoa/Cocoa.h>


@interface NSMenu (RepresentMore)

/*!
 @brief    Iterates through the receiver's -itemArray and returns
 the item whose representedObject -isEqual to a given object

 @details  If no such object is found, returns nil
*/
- (NSMenuItem*)itemWithRepresentedObject:(id)object ;

@end
