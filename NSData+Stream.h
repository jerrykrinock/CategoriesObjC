#import <Cocoa/Cocoa.h>

/*!
 @brief    A category for reading from and writing NSData
 objects to unix FILE streams such as the 'stdin', 'stdout'
 and 'stderr' macros defined in stdio.h.
*/
@interface NSData (Stream)

/*!
 @brief    Returns an autoreleased NSData object
 containing the bytes from a given stream.
*/
+ (NSData*)dataWithStream:(FILE*)stream ;

/*!
 @brief    Writes the bytes of the receiver to a
 given stream.
*/
- (void)writeToStream:(FILE*)stream ;
	

@end
