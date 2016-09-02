#import <Foundation/Foundation.h>

@interface NSString (SSYDotSuffix)

/*!
 @brief   Returns a replica of the receiver with a given suffix, separated
 from the original string by a dot '.' character, or if the given suffix is
 nil, the receiver itself
 
 @details  This is a replacement for stringByAppendingPathExtension: in macOS
 10.12 Sierra, wherein stringByAppendingPathExtension: will return nil if the
 parameter contains any space characters.
 */
- (NSString*)stringByAppendingDotSuffix:(NSString*)suffix ;

/*!
 @brief   Returns a replica of the receiver with the last dot '.' character in
 it, and any trailing characters after that dot '.' removed, or if the receiver
 does not contain any dot '.' charcters, the receiver itself
 
 @details  This is a replacement for stringByDeletingPathExtension in macOS
 10.12 Sierra, wherein stringByDeletingPathExtension will not recognize a path
 extension which contains anyspace characters.
 */
- (NSString*)stringByDeletingDotSuffix ;

@end
