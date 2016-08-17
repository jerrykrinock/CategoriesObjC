#import <Foundation/Foundation.h>

@interface NSString (SSYFileExtensions)

/*!
 @brief   Wrapper around -stringByAppendingPathExtension: which first replaces
 any space characters in the given parameter with an underscore
 
 @details  This is necessary in macOS 10.12 Sierra, wherein -[NSString
 stringByAppendingPathExtension: will return nil if the parameter contains any
 space characters.
 */
- (NSString*)stringByLossilyAppendingPathExtension:(NSString*)extension ;

@end
