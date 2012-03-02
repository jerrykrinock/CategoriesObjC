#import <Cocoa/Cocoa.h>


@interface NSFileHandle (SSYExtras)

/*!
 @brief    An augmentation upon +fileHandleForWritingAtPath: which first
 creates the file if it does not exist, or clears out all existing data
 if the file does exist
*/
+ (NSFileHandle*)clearateFileHandleForWritingAtPath:(NSString*)path ;

@end
