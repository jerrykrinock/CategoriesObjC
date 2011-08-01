#import <Cocoa/Cocoa.h>

@interface NSData(HexCharacterStrings)

/*!
 @brief    Method for converting a string containing hex character
 such as @"00a34f52 ff0001" to an NSData.

 @details  Useful on the strings you get when you NSLog the
 description of an NSData, for reproducing bugs.
 @param    string  Some restrictions apply.  See source code :)
*/
+ (NSData*)dataWithHexCharacterString:(NSString*)string ;

@end

